source 'https://rubygems.org'
source 'http://gems.github.com'
ruby "2.3.5"

gem 'puma'

gem 'rails_12factor'
gem 'rails', '5.0.0'
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
gem 'sendgrid-ruby', '~> 5.0', git: 'https://github.com/allhailskippy/sendgrid-ruby.git', branch: 'rails-5'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'ruby_parser'

# Javascript gems
gem 'jquery-rails'
gem 'jquery-ui-rails'

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-angular'
  gem 'rails-assets-leaflet'
  gem 'rails-assets-holderjs'
end
gem 'ng-rails-csrf'

# Permission Gems
gem 'devise'
gem 'pundit'
gem 'omniauth-google-oauth2'
gem 'userstamp', git: 'https://github.com/allhailskippy/userstamp.git', branch: 'rails-5'

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
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'database_cleaner'
  gem 'site_prism'
  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'byebug'
end
