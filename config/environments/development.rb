Youtubetonight::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # config.whiny_nils = true

  config.log_level = :debug

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Do not compress assets
  config.assets.js_compressor = :uglifier

  # Expands the lines which load the assets
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  config.eager_load = false

  # Removing for websocket-rails gem
  config.middleware.delete Rack::Lock

  # YouTube
  YOUTUBE_API_KEY = ENV['YOUTUBE_API_KEY']
 
  GOOGLE_CLIENT_ID = ENV['GOOGLE_CLIENT_ID']
  GOOGLE_CLIENT_SECRET = ENV['GOOGLE_CLIENT_SECRET']

  # Facebook
  FACEBOOK_KEY = ENV['FACEBOOK_KEY']
  FACEBOOK_SECRET = ENV['FACEBOOK_SECRET']

  # Websockets
  WEBSOCKET_URL = ENV['WEBSOCKET_URL']

  SYSTEM_ADMIN_ID = ENV['SYSTEM_ADMIN_ID']
end
