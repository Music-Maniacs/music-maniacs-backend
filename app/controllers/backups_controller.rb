class BackupsController < ApplicationController
  BACKUP_DIR = File.expand_path('~/backups/mm_backup').freeze
  CONTAINER_NAME = 'docker_services-db-1'.freeze
  USER_DB = 'docker'.freeze
  DB = 'music_maniacs_backend_development'.freeze

  def index
    backup_data = Dir.glob("#{BACKUP_DIR}/*").map do |folder|
      folder_size_bytes = Dir.glob("#{folder}/**/*").select { |f| File.file?(f) }.map { |f| File.size(f) }.sum
      folder_size_megabytes = folder_size_bytes / 1_048_576.0  # Convertir bytes a megabytes
      {
        name: File.basename(folder),
        size_megabytes: folder_size_megabytes.round(2), # Tamaño MB
        date: extract_date_from_filename(File.basename(folder)), # Fecha de la última modificación del directorio
        path: folder
      }
    end

    if backup_data.present?
      render json: backup_data, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def restore_backup
    selected_backup = params[:id]
    backup_file_path = "#{BACKUP_DIR}/#{selected_backup}/mm_backup/databases/PostgreSQL.sql"
    tar_file_path = "#{BACKUP_DIR}/#{selected_backup}" # Cambio aquí

    # Limpiar la base de datos antes de restaurar el backup
    clean_database

    # Ruta para restaurar la base de datos desde el archivo PostgreSQL.sql
    restore_command = "sudo docker exec -i #{CONTAINER_NAME} psql -U #{USER_DB} -d #{DB} < #{backup_file_path}"

    # Descomprime y restaura
    system("cd #{tar_file_path} && tar -xf mm_backup.tar") # descomprime
    system(restore_command) # restaura la db

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
      head :no_content
    else
      render json: { error: 'El directorio de backup no existe' }, status: :not_found
    end
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
end
