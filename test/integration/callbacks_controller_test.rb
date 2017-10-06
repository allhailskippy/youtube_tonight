require 'test_helper'

class CallbacksControllerTest < ActionDispatch::IntegrationTest
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing '/users/auth/google_oauth2/callback', controller: 'callbacks', action: 'google_oauth2'
  end
end
