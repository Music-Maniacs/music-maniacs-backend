url = ENV.fetch('REDIS_CONNECTION_STRING', "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/#{ENV['REDIS_DB']}")

Sidekiq.configure_server do |config|
  config.redis = { url: }
end

Sidekiq.configure_client do |config|
  config.redis = { url: }
end
