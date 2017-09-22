ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'sidekiq/testing'
require 'mocha/mini_test'

['helpers'].each do |lib|
  Dir["#{File.dirname(__FILE__)}/#{lib}/**/*.rb"].each {|f| require f}
end

class ActiveSupport::TestCase
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Devise::Test::ControllerHelpers
  include FactoryGirl::Syntax::Methods
  include Permissions

  def create_user(options = {})
    create(:user, options)
  end

  def setup
    Authorization.current_user = User.find(SYSTEM_ADMIN_ID)
    User.stamper = Authorization.current_user
  end
end
