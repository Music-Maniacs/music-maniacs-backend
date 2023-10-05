# encoding: utf-8

##
# Backup
# Generated Main Config Template
#
# For more information:
#
# View the Git repository at https://github.com/meskyanichi/backup
# View the Wiki/Documentation at https://github.com/meskyanichi/backup/wiki
# View the issue log at https://github.com/meskyanichi/backup/issues

##
# Utilities
#
# If you need to use a utility other than the one Backup detects,
# or a utility can not be found in your $PATH.
#
Backup::Utilities.configure do
  pg_dump '/usr/bin/pg_dump'  # Debe apuntar a la ruta dentro del contenedor
end

##
# Logging
#
# Logging options may be set on the command line, but certain settings
# may only be configured here.
#
Backup::Logger.configure do
  # Logfile options:
  # console.quiet     = true # quitar el commentario
  logfile.enabled   = true 
  logfile.log_path  = 'log'
  logfile.max_bytes = 500_000
end
#
# Command line options will override those set here.
# For example, the following would override the example settings above
# to disable syslog and enable console output.
#   backup perform --trigger my_backup --no-syslog --no-quiet


# * * * * * * * * * * * * * * * * * * * *
#        Do Not Edit Below Here.
# All Configuration Should Be Made Above.

##
# Load all models from the models directory.
Dir[File.join(File.dirname(Config.config_file), "models", "*.rb")].each do |model|
  instance_eval(File.read(model))
end
