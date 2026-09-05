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

ENV['THOR_SILENCE_DEPRECATION'] ||= '1'

require 'yaml'
require 'backup'

require 'psych'

class Psych::ClassLoader::Restricted
  alias_method :orig_find, :find rescue nil
  def find(klassname)
    if klassname == 'Backup::Package' || klassname.start_with?('Backup::')
      super(klassname)
    else
      orig_find(klassname)
    end
  end
end

begin
  require 'dotenv'
  Dotenv.load(File.expand_path('../../.env', __dir__))
rescue LoadError
  # Dotenv not loaded
end

##
# Utilities
#
# If you need to use a utility other than the one Backup detects,
# or a utility can not be found in your $PATH.
#
::Backup::Utilities.configure do
  pg_dump_path = ENV['PG_DUMP_PATH'] || `which pg_dump 2>/dev/null`.strip
  pg_dump pg_dump_path.empty? ? '/usr/bin/pg_dump' : pg_dump_path
end

##
# Logging
#
# Logging options may be set on the command line, but certain settings
# may only be configured here.
#
Backup::Logger.configure do
  # Logfile options:
  console.quiet     = true # quitar el commentario para no mostrar informacion en consola
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
