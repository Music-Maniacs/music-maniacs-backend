# Load the Rails application.
require_relative "application"

REACT_HOST = ENV['REACT_HOST'] || 'http://localhost:3001'

# Initialize the Rails application.
Rails.application.initialize!
