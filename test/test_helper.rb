ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'sidekiq/testing'
require 'mocha/mini_test'
require 'minitest/retry'
require 'webmock/rspec'
require 'webmock/minitest'

Minitest::Retry.use!(verbose: false, retry_count: 5)
WebMock.disable_net_connect!(allow_localhost: true)

['helpers'].each do |lib|
  Dir["#{File.dirname(__FILE__)}/#{lib}/**/*.rb"].each {|f| require f}
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def setup
    Authorization.current_user = User.find(SYSTEM_ADMIN_ID)
    User.stamper = Authorization.current_user
  end
end

class ActionDispatch::IntegrationTest
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Devise::Test::IntegrationHelpers
  include Permissions

  def create_user(options = {})
    create(:user, options)
  end
end
