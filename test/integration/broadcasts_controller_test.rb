require 'test_helper'

class BroadcastsControllerTest < ActionDispatch::IntegrationTest
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing '/broadcasts', controller: 'broadcasts', action: 'index'
  end

  ##
  # Index
  ##
  test 'Admin: should get index as html' do
    authenticate_as_admin

    get broadcasts_url(format: :html)
    assert_response :success
    assert_template :index, layout: 'broadcasts'
  end

  test 'Host: should get index as html' do
    authenticate_as_host

    get broadcasts_url(format: :html)
    assert_response :success
    assert_template :index, layout: 'broadcasts'
  end

  test 'Guest: should get index as html' do
    get broadcasts_url(format: :html)
    assert_redirected_to  '/users/sign_in'
  end
end
