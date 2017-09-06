source 'https://rubygems.org'
ruby "2.2.3"

group :production do
  gem 'thin'
end

gem 'rails_12factor'
gem 'rails', '4.2.9'
gem 'test-unit'
gem 'bundler', '>= 1.8.4'

gem 'httparty'
gem 'pg', '0.20.0'
gem 'date_validator'
gem 'ransack'
gem 'will_paginate'
gem 'validate_url'
gem 'acts_as_versioned'
gem "paranoia", "~> 2.0"
gem 'iso8601'
gem 'delayed_job_active_record'
gem 'eventmachine', '1.0.9.1'
gem 'newrelic_rpm'
gem 'sendgrid-ruby'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'ruby_parser'

# Javascript gems
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'faye-websocket', '0.7.5'
gem 'websocket-rails', :git => 'https://github.com/websocket-rails/websocket-rails.git', :branch => 'master'

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-angular'
  gem 'rails-assets-leaflet'
  gem 'rails-assets-holderjs'
end
gem 'ng-rails-csrf'

# Permission Gems
gem 'devise'
gem 'declarative_authorization', :git => 'https://github.com/stffn/declarative_authorization.git'
gem 'omniauth-google-oauth2'
gem 'userstamp', :git => 'https://github.com/kimkong/userstamp.git'

# APIs
gem 'google-api-client', '0.11'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

group :test do
  gem 'mocha'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'webmock'
  gem 'mock_redis'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'database_cleaner'
end

group :development, :test do
  gem 'byebug'
end
