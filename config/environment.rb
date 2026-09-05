# Load the Rails application.
require_relative "application"

REACT_HOST = ENV.fetch('REACT_HOST')

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.default_url_options = Rails.application.config.action_mailer.default_url_options