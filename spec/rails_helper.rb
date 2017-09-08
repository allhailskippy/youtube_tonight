# To run with a browser:
#   HEADLESS=false rspec spec/features/test_name
#
# In headless mode, print console.logs to the terminal:
#   JSLOG=1 rspec spec/features/something
#
# In non-headless mode, slow down interaction with the browser:
# (useful for debugging synchronization problems)
#   SLOW=1 rspec spec/features/something
#
# Take a screenshot everytime a failure occurs:
#   FAILURE_SCREENSHOTS=1 rspec spec/features/something

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

if ENV['COVERAGE'] == 'on'
  require 'simplecov'
  SimpleCov.command_name "Test process number #{Process.pid}"
  SimpleCov.start 'rails'
elsif ENV['COVERAGE'] == 'rcov'
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.command_name "#{Process.pid}"
  SimpleCov.start 'rails'
end

require 'spec_helper'
require 'rspec/rails'
require 'capybara'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'sidekiq/testing'
require 'declarative_authorization/maintenance'
require 'selenium-webdriver'
require 'site_prism'

require_relative 'helpers/spec_helpers.rb'

# Require libraries
['support', 'pages'].each do |lib|
  Dir["#{File.dirname(__FILE__)}/#{lib}/**/*.rb"].each {|f| require f}
end

if %w(false f no n).include?(ENV['HEADLESS'].to_s.downcase)
  Capybara.javascript_driver = :selenium

  # How to install chrome driver:
  #   http://www.kenst.com/2015/03/installing-chromedriver-on-mac-osx/
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.javascript_driver = :chrome

  if %w(true t yes y 1).include?(ENV['SLOW'].to_s.downcase)
    module ::Selenium::WebDriver::Remote
      class Bridge
        def execute(*args)
          res = raw_execute(*args)['value']
          sleep 0.15
          res
        end
      end
    end
  end
else
  Capybara.register_driver :poltergeist do |app|
    opts = { port: 51_674, phantomjs: Phantomjs.path}

    unless ENV['JSLOG'].present?
      null_logger = File.open(File::NULL, 'w')
      opts[:phantomjs_logger] = null_logger
    end

    Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
  end
  Capybara.javascript_driver = :poltergeist
end

WebMock.disable_net_connect!(allow_localhost: true)
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryGirl::Syntax::Methods
  config.include Authorization::Maintenance
  config.include SpecHelpers
  config.include Warden::Test::Helpers

  # Setting up rspec retry because we get some false negatives sometimes
  config.verbose_retry = true
  config.display_try_failure_messages = true
  config.default_retry_count = 5 if ENV['RETRY'].present?
  config.global_fixtures = :all

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    Authorization.current_user = User.find(SYSTEM_ADMIN_ID)
  end

  config.around do |example|
    # Using deletion otherwise running on CI gets too slow (+30s per test)
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.start

    example.run

    DatabaseCleaner.clean
  end

  config.after(:each) do |example|
    Warden.test_reset!
    screenshot if %w(true t yes y 1).include?(ENV['FAILURE_SCREENSHOTS'].to_s.downcase) && example.exception
  end
end
