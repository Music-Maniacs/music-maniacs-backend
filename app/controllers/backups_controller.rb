class BackupsController < ApplicationController
  BACKUP_DIR = File.expand_path('~/backups/mm_backup').freeze
  CONTAINER_NAME = 'docker_services-db-1'.freeze
  USER_DB = 'docker'.freeze
  DB = 'music_maniacs_backend_development'.freeze

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
    backup_file_path = "#{BACKUP_DIR}/#{selected_backup}/mm_backup/databases/PostgreSQL.sql"
    tar_file_path = "#{BACKUP_DIR}/#{selected_backup}" # Cambio aquí

    # Limpiar la base de datos antes de restaurar el backup
    clean_database

    # Ruta para restaurar la base de datos desde el archivo PostgreSQL.sql
    restore_command = "sudo docker exec -i #{CONTAINER_NAME} psql -U #{USER_DB} -d #{DB} < #{backup_file_path}"

    # Descomprime y restaura
    system("cd #{tar_file_path} && tar -xf mm_backup.tar") # descomprime
    system(restore_command) # restaura la db

    head :no_content
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
end
