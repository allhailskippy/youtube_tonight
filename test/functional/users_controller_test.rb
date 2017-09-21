class UsersControllerTest < ActionController::TestCase
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing('/users.json', controller: 'users', action: 'index', format: 'json')
    assert_routing('/users/1.json', controller: 'users', action: 'show', id: '1', format: 'json')
    assert_routing({ method: 'put', path: '/users/1.json'}, { controller: 'users', action: 'update', id: '1', format: 'json'})
    assert_routing({ method: 'delete', path: '/users/1.json'}, { controller: 'users', action: 'destroy', id: '1', format: 'json'})
    assert_routing('/users/1/requires_auth', controller: 'users', action: 'requires_auth', id: '1')
  end

  ##
  # Requires Auth
  ##
  test 'Admin: should show the requires auth page' do
    admin = create_user(role_titles: [:admin], requires_auth: true)
    login_as(admin)

    get :requires_auth, id: admin.id.to_s

    assert_response :success
    assert_template :requires_auth
  end

  test 'Admin: should not show auth page when requires_auth is false' do
    admin = create_user(role_titles: [:admin], requires_auth: false)
    login_as(admin)

    get :requires_auth, id: admin.id.to_s

    assert_redirected_to '/'
  end

  ##
  # Index
  ##
  test 'Admin: should get users index' do
    # Don't let fixtures get in the way, keep system admin (should not be found)
    User.where('id != ?', SYSTEM_ADMIN_ID).delete_all

    admin = create_user(role_titles: [:admin])
    login_as(admin)

    u1 = without_access_control { create(:user) }
    u2 = without_access_control { create(:user) }

    get :index, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all users
    assert_equal 3, results["data"].length
    expected = [
      JSON.parse(u2.to_json),
      JSON.parse(u1.to_json),
      JSON.parse(admin.to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Admin: should get index with custom params' do
    # Don't let fixtures get in the way, keep system admin (should not be found)
    User.where('id != ?', SYSTEM_ADMIN_ID).delete_all

    # Counts as first user (hence 11 later on)
    admin = create_user(role_titles: [:admin])
    login_as(admin)

    users = without_access_control { 10.times.map { create(:user) } }

    get :index, format: :json, q: { s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 11, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all users for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(users[2].to_json),
      JSON.parse(users[3].to_json),
      JSON.parse(users[4].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Admin: cannot set page < 1' do
    admin = login_as_admin

    p1 = without_access_control { create(:user) }

    get :index, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Admin: index should handle an exception' do
    User.stubs(:without_system_admin).raises(Exception.new("Random Exception"))
    login_as_admin

    get :index, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host : index should get redirected to login' do
    login_as_host

    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  test 'Guest: index should get redirected to login' do
    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Show
  ##
  test 'Admin: should get own user' do
    admin = login_as_admin

    u1 = without_access_control { create(:user) }

    get :show, id: u1.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(u1.to_json), results["data"]
  end

  test 'Admin: should get another user' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin

    u = without_access_control { create(:user) }

    get :show, id: u.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(u.to_json), results["data"]
  end

  test 'Admin: should not find nonexistant user' do
    login_as_admin

    get :show, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: user should handle an exception' do
    admin = login_as_admin
    User.stubs(:find).raises(Exception.new("Random Exception"))

    get :show, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: should get own user' do
    host = login_as_host

    get :show, id: host.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    u = User.find(host.id)
    assert_equal JSON.parse(u.to_json), results["data"]
  end

  test 'Host: should get another user' do
    user = create_user(role_titles: [:host])
    host = login_as_host

    u = without_access_control { create(:user, role_titles: [:admin]) }

    get :show, id: u.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(u.to_json), results["data"]
  end

  test 'Host: should not find nonexistant user' do
    login_as_host

    get :show, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: user should handle an exception' do
    host = login_as_host
    User.stubs(:find).raises(Exception.new("Random Exception"))

    get :show, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: user should get redirected to login' do
    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Update
  ##
  test 'Admin: should not update own user' do
    skip 'Fix this in TID-102'
  end

  test 'Admin: can update another user' do
    admin = login_as_admin
    user = create_user(role_titles: [:host])

    user = create(:user, email: 'original@email.com', role_titles: [:admin], name: 'Original Name', requires_auth: true)
    user_params = {
      name: 'New Name',
      email: 'new@email.org',
      requires_auth: 'false',
      change_roles: 'true',
      role_titles: ['host']
    }
    put :update, id: user.id.to_s, user: user_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    user = User.find(user.id)
    assert_equal JSON.parse(user.to_json), results["data"]

    assert_equal "New Name", results["data"]["name"]
    assert_equal "new@email.org", results["data"]["email"]
    assert_equal false, results["data"]["requires_auth"]
    assert_equal ["host"], results["data"]["role_titles"]
  end

  test 'Admin: update should fail validation' do
    admin = login_as_admin
    user = create(:user)
    user_params = {
      name: '',
      email: '',
      requires_auth: '',
      change_roles: 'true'
    }
    post :update, id: user.id.to_s, user: user_params, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_not_empty results

    errors = [
      "Name can't be blank",
      "Email can't be blank",
      "Roles must be selected"
    ]
    errors.each do |error|
      assert results["full_errors"].include?(error)
    end
    assert_equal 3, results["full_errors"].length

    assert_equal ["can't be blank"], results["errors"]["name"]
    assert_equal ["can't be blank"], results["errors"]["email"]
    assert_equal ["must be selected"], results["errors"]["role_titles"]
  end

  test 'Admin: update should handle user not found' do
    login_as_admin

    put :update, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: update should handle exception' do
    admin = login_as_admin

    User.stubs(:find).raises(Exception.new("Random Exception"))

    put :update, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot update users' do
    login_as_host

    put :update, id: 'whatever', user: {}, format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Guest: update should get redirected to login' do
    put :update, id: 'whatever', format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Destroy
  ##
  test 'Admin: can delete a user' do
    admin = login_as_admin

    user = create(:user)

    delete :destroy, id: user.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      User.find(user.id)
    end
  end

  test 'Admin: destroy should handle user not found' do
    login_as_admin

    delete :destroy, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: destroy should handle exception' do
    admin = login_as_admin

    User.stubs(:find).raises(Exception.new("Random Exception"))

    delete :destroy, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot destroy users' do
    login_as_host

    delete :destroy, id: 'whatever', user: {}, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  test 'Guest: destroy should get redirected to login' do
    user = create(:user)

    delete :destroy, id: user.id.to_s, format: :json
    assert_redirected_to  '/users/sign_in'
  end
end
