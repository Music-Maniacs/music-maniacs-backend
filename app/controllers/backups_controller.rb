class BackupsController < ApplicationController
  before_action :authenticate_user!
  BACKUP_DIR = File.expand_path('~/backups/mm_backup').freeze
  MULTIMEDIA_DIR = File.expand_path('./storage').freeze
  CONTAINER_NAME = 'docker_services-db-1'.freeze
  USER_DB = 'docker'.freeze
  DB = 'music_maniacs_backend_development'.freeze

  def index
    dir = Dir.glob("#{BACKUP_DIR}/*")

    paginated_backups = Kaminari.paginate_array(dir).page(params[:page]).per(params[:per_page])

    backup_data = paginated_backups.map do |folder|
      folder_size_bytes = Dir.glob("#{folder}/**/*").select { |f| File.file?(f) }.map { |f| File.size(f) }.sum
      folder_size_megabytes = folder_size_bytes / 1_048_576.0 # Convertir bytes a megabytes

      {
        name: File.basename(folder),
        size_megabytes: folder_size_megabytes.round(2), # Tamaño MB
        date: extract_date_from_filename(File.basename(folder)), # Fecha de la última modificación del directorio
        path: folder
      }
    end
    render json: { data: backup_data, pagination: { total: dir.size } }, status: :ok
  end

  def restore_backup
    selected_backup = params[:id]
    backup_file_path = "#{BACKUP_DIR}/#{selected_backup}/mm_backup/databases/PostgreSQL.sql"
    tar_file_path = "#{BACKUP_DIR}/#{selected_backup}"
    path_multimedia = "#{BACKUP_DIR}/#{selected_backup}/multimedia*"

    # Limpiar la base de datos antes de restaurar el backup
    clean_database

    # Ruta para restaurar la base de datos desde el archivo PostgreSQL.sql
    restore_command = "sudo docker exec -i #{CONTAINER_NAME} psql -U #{USER_DB} -d #{DB} < #{backup_file_path}"

    # Descomprime y restaura
    system("cd #{tar_file_path} && tar -xf mm_backup.tar") # descomprime
    system(restore_command) # restaura la db

    matching_files = Dir.glob(path_multimedia)

    multimedia_restore(matching_files) if params[:multimedia].present? && params[:multimedia] == true

    head :no_content, status: :ok
  rescue StandardError => e
    render json: { error: "Error al restaurar el backup: #{e.message}" }, status: :not_found
  end

  def destroy
    selected_backup = params[:id]
    backup_file_path_delete = "#{BACKUP_DIR}/#{selected_backup}"
    # Existe el directorio?
    if Dir.exist?(backup_file_path_delete)
      FileUtils.rm_rf(backup_file_path_delete) # Borra el directorio y su contenido
      head :no_content, status: :ok
    else
      render json: { error: 'El directorio de backup no existe' }, status: :not_found
    end
  end

  def create
    system('backup perform -t mm_backup -c ./config/backup/config.rb')
    dir = Dir.glob("#{BACKUP_DIR}/*")
    latest_folder = dir.max_by { |folder| File.ctime(folder) }

    multimedia_create(latest_folder) if params[:multimedia].present? && params[:multimedia] == true # backup multimedia

    # Despues de todas las operaciones calculo el tamaño

    folder_size_bytes = Dir.glob("#{latest_folder}/**/*").select { |f| File.file?(f) }.map { |f| File.size(f) }.sum
    folder_size_megabytes = folder_size_bytes / 1_048_576.0 # Convertir bytes a megabytes

    latest_backup_info = {
      name: File.basename(latest_folder),
      size_megabytes: folder_size_megabytes.round(2), # Tamaño MB
      date: extract_date_from_filename(File.basename(latest_folder)), # Fecha de la última modificación del directorio
      path: latest_folder
    }
    render json: latest_backup_info, status: :ok
  rescue StandardError => e
    render json: { error: "Error al crear el backup: #{e.message}" }, status: :not_found
  end

  private

  def clean_database
    clean_database_command = "sudo docker exec -i #{CONTAINER_NAME} psql -U #{USER_DB} -d #{DB} -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'"
    system(clean_database_command) # limpia la db
  end

  def extract_date_from_filename(filename)
    # Suponemos que el formato del nombre del archivo es "YYYY.MM.DD.HH.MM.SS.extensión"

    # Extraer la parte de la fecha del nombre del archivo
    date_str = filename.match(/\d{4}\.\d{2}\.\d{2}\.\d{2}\.\d{2}\.\d{2}/).to_s

    # Convertir la cadena de fecha a un objeto de fecha
    DateTime.strptime(date_str, '%Y.%m.%d.%H.%M.%S')
  end

  def multimedia_restore(path_multimedia)
    temp_extract_dir = "#{MULTIMEDIA_DIR}/temp_extract" # Carpeta temporal

    FileUtils.mkdir_p(temp_extract_dir) # Crear carpeta temporal si no existe

    # Copiar el archivo comprimido a la carpeta temporal
    FileUtils.cp_r(path_multimedia, temp_extract_dir)

    # Descomprimir el archivo TAR en la carpeta temporal
    system("cd #{temp_extract_dir} && tar -xf multimedia*.tar")

    # Copiar los archivos extraídos al directorio MULTIMEDIA_DIR
    FileUtils.cp_r("#{temp_extract_dir}/.", MULTIMEDIA_DIR)

    # Eliminar el archivo TAR
    tar_file = Dir.glob("#{MULTIMEDIA_DIR}/multimedia*.tar")
    FileUtils.rm(tar_file)

    # Eliminar la carpeta temporal
    FileUtils.rm_r(temp_extract_dir)
  end

  def multimedia_create(latest_folder)
    storage_directory = MULTIMEDIA_DIR
    backup_directory = latest_folder

    # Nombre del archivo de respaldo comprimido
    backup_filename = "multimedia-#{Time.now.strftime('%Y%m%d%H%M%S')}.tar"

    # Comprimir el directorio de almacenamiento en un archivo TAR
    Dir.chdir(storage_directory) do
      system("tar -cvf #{backup_filename} .")
    end

    # Mover el archivo comprimido a la carpeta de backups
    FileUtils.mv("#{storage_directory}/#{backup_filename}", backup_directory)
  end
end
