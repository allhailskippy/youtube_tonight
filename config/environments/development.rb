yml_section = Rails.env.to_s
yml_file = YAML.load(File.open(File.join(Rails.root.to_s, 'config', 'environments', 'credentials.yml')))
credentials = yml_file[yml_section]

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
  YOUTUBE_API_KEY = credentials['youtube_api_key']
 
  GOOGLE_CLIENT_ID = credentials['google_client_id']
  GOOGLE_CLIENT_SECRET = credentials['google_client_secret']

  # Facebook
  FACEBOOK_KEY = credentials['facebook_key']
  FACEBOOK_SECRET = credentials['facebook_secret']

  # Websockets
  WEBSOCKET_URL = credentials['websocket_url']

  SYSTEM_ADMIN_ID = ENV['SYSTEM_ADMIN_ID']
end
