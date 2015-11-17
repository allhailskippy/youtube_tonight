source 'https://rubygems.org'
ruby "2.2.3"

group :production do
  gem 'thin'
end
gem 'rails_12factor'
gem 'rails', '3.2.21'
gem 'test-unit'
gem 'bundler', '>= 1.8.4'
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-rvm'
gem 'capistrano-bundler'
group :production do
#  gem 'therubyracer', :platforms => :ruby
end

gem 'pg'
gem 'date_validator'
gem 'ransack'
gem 'will_paginate', '3.0.7'
gem 'validate_url'
gem 'acts_as_versioned', :path => 'vendor/gems/acts_as_versioned' # https://github.com/technoweenie/acts_as_versioned
gem 'rails3_acts_as_paranoid'
gem 'iso8601'

# Javascript gems
gem 'jquery-rails', '2.3.0'
gem 'jquery-ui-rails'
gem 'websocket-rails'

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-angular'
  gem 'rails-assets-leaflet'
  gem 'rails-assets-holderjs'
end
gem 'ng-rails-csrf'

# Permission Gems
gem 'devise'
gem 'declarative_authorization'
gem 'omniauth-facebook'
gem 'userstamp', :path => './lib/plugins/userstamp'

# APIs
gem 'google-api-client'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
