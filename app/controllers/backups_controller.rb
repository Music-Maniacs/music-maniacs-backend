class BackupsController < ApplicationController
  BACKUP_DIR = File.expand_path('~/backups/mm_backup').freeze

  def list_backups
    backup_files = Dir.glob("#{BACKUP_DIR}/*").map { |folder| File.basename(folder) }
    render json: backup_files, status: :ok
  rescue StandardError => e
    render json: { error: "Error al obtener la lista de backups: #{e.message}" }, status: :unprocessable_entity
  end

  def restore_backup
    selected_backup = params[:id]
    container_name = "docker_services-db-1"
    db = "music_maniacs_backend_development"
    user = "docker"
    backup_file_path = "#{BACKUP_DIR}/#{selected_backup}/mm_backup/databases/PostgreSQL.sql"
    tar_file_path = "tar -xf #{BACKUP_DIR}/#{selected_backup}/*"
  
    # restuarar la base de datos desde el archivo PostgreSQL.sql
    restore_command = "sudo docker exec -i #{container_name} psql -U #{user} -d #{db} < #{backup_file_path}"
    
    system(tar_file_path) # borrar el archivo que se descomprimio
    system(restore_command)
  
    render json: { message: 'Backup restaurado exitosamente' }, status: :ok
  rescue StandardError => e
    render json: { error: "Error al restaurar el backup: #{e.message}" }, status: :unprocessable_entity
  end
  
end
  