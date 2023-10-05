# encoding: utf-8

##
# Backup Generated: mm_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t mm_backup [-c <path_to_configuration_file>]
#
# # load login info
# db_config = YAML.load_file('./config/database.yml')['development']

Backup::Model.new(:mm_backup, 'Description for mm_backup') do
  # PostgreSQL [Database]
  database PostgreSQL do |db|
    db.name           = 'music_maniacs_backend_development'
    db.username       = 'docker'
    db.password       = 'docker'
    db.host           = 'localhost'
    db.port           = 5432
    # db.pg_dump_path   = '/usr/bin/pg_dump'
    # db.socket         = '/tmp'
    # db.skip_tables        = ['users', 'active_storage_blobs', 'versions']
    # db.only_tables        = ["only", "these", "tables"]
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = '~/backups/'
    local.keep       = 7
  end

  # Gzip [Compressor]
  # compress_with Gzip

  # # Mail [Notifier]
  # notify_by Mail do |mail|
  #   mail.on_success         = false
  #   mail.on_warning         = true
  #   mail.on_failure         = true

  #   mail.from               = app_config['email_username']
  #   mail.to                 = app_config['email_username']
  #   mail.address            = app_config['email_address']
  #   mail.port               = app_config['email_port']
  #   mail.domain             = app_config['email_domain']
  #   mail.user_name          = app_config['email_username']
  #   mail.password           = app_config['email_password']
  #   mail.authentication     = :login
  #   mail.encryption         = :ssl
  # end
  split_into_chunks_of 250
end
