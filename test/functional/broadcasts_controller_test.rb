class BroadcastsControllerTest < ActionController::TestCase
  ##
  # Routes
  ##
  test 'Admin: should check routes' do
    login_as_admin
    assert_routing '/broadcasts', controller: 'broadcasts', action: 'index'
  end

  test 'Host: should check routes' do
    login_as_host
    assert_routing '/broadcasts', controller: 'broadcasts', action: 'index'
  end

  test 'Guest: should check routes' do
    assert_routing '/broadcasts', controller: 'broadcasts', action: 'index'
  end

  ##
  # Index
  ##
  test 'Admin: should get index as html' do
    login_as_admin

    get :index, format: :html
    assert_response :success
    assert_template :index, layout: 'broadcasts'
  end

  test 'Host: should get index as html' do
    login_as_host

    get :index, format: :html
    assert_response :success
    assert_template :index, layout: 'broadcasts'
  end

  test 'Guest: should get index as html' do
    get :index, format: :html
    assert_redirected_to  '/users/sign_in'
  end
end
