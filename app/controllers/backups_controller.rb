class BackupsController < ApplicationController
  BACKUP_DIR = File.expand_path('~/backups/mm_backup').freeze

  def index
    backup_files = Dir.glob("#{BACKUP_DIR}/*").map { |folder| File.basename(folder) }
    if backup_files.present?
      render json: backup_files, status: :ok
    else
      render json: backup_files.errors, status: :unprocessable_entity
    end
  end

  def restore_backup
    selected_backup = params[:id]
    container_name = 'docker_services-db-1'
    db = 'music_maniacs_backend_development'
    user = 'docker'
    backup_file_path = "#{BACKUP_DIR}/#{selected_backup}/mm_backup/databases/PostgreSQL.sql"
    tar_file_path = "#{BACKUP_DIR}/#{selected_backup}.tar" # Cambio aquí

    # Limpiar la base de datos antes de restaurar el backup
    clean_database_command = "sudo docker exec -i #{container_name} psql -U #{user} -d #{db} -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'"

    # Restaurar la base de datos desde el archivo PostgreSQL.sql
    restore_command = "sudo docker exec -i #{container_name} psql -U #{user} -d #{db} < #{backup_file_path}"

    # Ejecutar los comandos para limpiar y restaurar la base de datos
    system(clean_database_command) # limpia la db
    system("tar -xf #{tar_file_path}") # descomprime
    system(restore_command) # restaura la db

    render json: { message: 'Backup restaurado exitosamente' }, status: :ok
  rescue StandardError => e
    render json: { error: "Error al restaurar el backup: #{e.message}" }, status: :unprocessable_entity
  end
end
