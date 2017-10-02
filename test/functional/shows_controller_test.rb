class ShowsControllerTest < ActionController::TestCase
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing('/shows.json', controller: 'shows', action: 'index', format: 'json')
    assert_routing('/shows/1.json', controller: 'shows', action: 'show', id: '1', format: 'json')
    assert_routing({ method: 'post', path: '/shows.json'}, { controller: 'shows', action: 'create', format: 'json' })
    assert_routing({ method: 'put', path: '/shows/1.json'}, { controller: 'shows', action: 'update', id: '1', format: 'json'})
    assert_routing({ method: 'delete', path: '/shows/1.json'}, { controller: 'shows', action: 'destroy', id: '1', format: 'json'})
  end

  ##
  # Index
  ##
  test 'Admin: should get index shows regardless of hosts' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin

    s1 = create(:show, users: [admin])
    s2 = create(:show, users: [admin, host])
    s3 = create(:show, users: [host])

    get :index, params: { format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all shows
    assert_equal 3, results["data"].length
    expected = [
      JSON.parse(s1.to_json),
      JSON.parse(s2.to_json),
      JSON.parse(s3.to_json)
    ]
    assert_equal expected, results["data"]

    # Check hosts explicitly
    assert_equal admin.id.to_s, results["data"][0]["hosts"]
    assert_equal [admin.id, host.id].join(','), results["data"][1]["hosts"]
    assert_equal host.id.to_s, results["data"][2]["hosts"]
  end

  test 'Admin: index should handle an exception' do
    Show::ActiveRecord_Relation.any_instance.stubs(:includes).raises(Exception.new("Random Exception"))
    login_as_admin

    get :index, params: { format: :json }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: should get index shows where host is a host' do
    user = create_user(role_titles: [:host])
    host = login_as_host

    s1 = create(:show, users: [host])
    s2 = create(:show, users: [user, host])
    s3 = create(:show, users: [user])

    get :index, params: { format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all shows that the host is hosting
    assert_equal 2, results["data"].length
    expected = [
      JSON.parse(s1.to_json),
      JSON.parse(s2.to_json)
    ]
    assert_equal expected, results["data"]

    # Check hosts explicitly
    assert_equal host.id.to_s, results["data"][0]["hosts"]
    assert_equal [user.id, host.id].sort.join(','), results["data"][1]["hosts"]
  end

  test 'Host: index should handle an exception' do
    Show::ActiveRecord_Relation.any_instance.stubs(:includes).raises(Exception.new("Random Exception"))
    login_as_host

    get :index, params: { format: :json }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: index should get redirected to login' do
    get :index, params: { format: :json }
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Show
  ##
  test 'Admin: should get show for own show' do
    admin = login_as_admin

    s1 = create(:show, users: [admin])

    get :show, params: { id: s1.id.to_s, format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(s1.to_json), results["data"]
  end

  test 'Admin: should get show for another users show' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin

    s1 = create(:show, users: [host])

    get :show, params: { id: s1.id.to_s, format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(s1.to_json), results["data"]
  end

  test 'Admin: should not find nonexistant show' do
    login_as_admin

    get :show, params: { id: 'nope', format: :json }
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: show should handle an exception' do
    Show.stubs(:find).raises(Exception.new("Random Exception"))
    admin = login_as_admin

    get :show, params: { id: 'whatever', format: :json }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: should get show for own show' do
    host = login_as_host

    p1 = create(:show, users: [host])

    get :show, params: { id: p1.id.to_s, format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(p1.to_json), results["data"]
  end

  test 'Host: should not get show for another users show' do
    user = create_user(role_titles: [:host])
    host = login_as_host

    p1 = create(:show, users: [user])

    get :show, params: { id: p1.id.to_s, format: :json }
    assert_response :unauthorized

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Unauthorized"], results["errors"]
  end

  test 'Host: should not find nonexistant show' do
    login_as_host

    get :show, params: { id: 'nope', format: :json }
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: show should handle an exception' do
    Show.stubs(:find).raises(Exception.new("Random Exception"))
    host = login_as_host

    get :show, params: { id: 'whatever', format: :json }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: show should get redirected to login' do
    get :show, params: { id: 'whatever', format: :json }
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Create
  ##
  test 'Admin: should create a show' do
    admin = login_as_admin
    user = create_user(role_titles: [:host])

    show_params = {
      air_date: Date.today.to_s(:db),
      title: 'Created Title',
      hosts: [admin.id, user.id].join(',')
    }

    post :create, params: { show: show_params, format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    show = Show.where(title: 'Created Title').first
    assert_equal JSON.parse(show.to_json), results["data"]
  end

  test 'Admin: should create show for a different user' do
    admin = login_as_admin
    user = create_user(role_titles: [:host])

    show_params = {
      air_date: Date.today.to_s(:db),
      title: 'Created Title',
      hosts: user.id.to_s
    }

    post :create, params: { show: show_params, format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    show = Show.where(title: 'Created Title').first
    assert_equal JSON.parse(show.to_json), results["data"]
  end

  test 'Admin: should fail validation' do
    admin = login_as_admin

    post :create, params: { show: {}, format: :json }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_not_empty results

    errors = [
      "Title can't be blank",
      "Air date is not a date",
      "Host must be selected"
    ]
    errors.each do |error|
      assert results["full_errors"].include?(error)
    end
    assert_equal 3, results["full_errors"].length

    assert_equal ["can't be blank"], results["errors"]["title"]
    assert_equal ["must be selected"], results["errors"]["hosts"]
    assert_equal ["is not a date"], results["errors"]["air_date"]
  end

  test 'Admin: create should handle exception' do
    Show.stubs(:new).raises(Exception.new("Random Exception"))
    login_as_admin

    post :create, params: { show: {}, format: :json }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot create shows' do
    login_as_host

    post :create, params: { show: {}, format: :json }
    assert_response :unauthorized

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Unauthorized"], results["errors"]
  end

  test 'Guest: create should get redirected to login' do
    post :create, params: { show: {}, format: :json }
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Update
  ##
  test 'Admin: should update show' do
    admin = login_as_admin
    user = create_user(role_titles: [:host])

    show = create(:show, users: [admin], title: 'Original Title', air_date: Date.today.to_s(:db))
    show_params = {
      title: "Updated Title",
      air_date: Date.tomorrow.to_s(:db),
      hosts: user.id.to_s
    }
    put :update, params: { id: show.id.to_s, show: show_params, format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    show = Show.find(show.id)
    assert_equal JSON.parse(show.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal Date.tomorrow.to_s(:db), results["data"]["air_date"]
    assert_equal user.id.to_s, results["data"]["hosts"]
  end

  test 'Admin: update should handle show not found' do
    login_as_admin

    put :update, params: { id: 'nope', format: :json }
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: update should handle exception' do
    admin = login_as_admin

    Show.stubs(:find).raises(Exception.new("Random Exception"))

    put :update, params: { id: 'whatever', format: :json }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot update show' do
    login_as_host
    show = create(:show)

    put :update, params: { id: show.id.to_s, show: {}, format: :json }
    assert_response :unauthorized

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Unauthorized"], results["errors"]
  end

  test 'Guest: update should get redirected to login' do
    show = create(:show)

    put :update, params: { id: show.id.to_s, format: :json }
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Destroy
  ##
  test 'Admin: can delete a show' do
    admin = login_as_admin

    show = create(:show)

    delete :destroy, params: { id: show.id.to_s, format: :json }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Show.find(show.id)
    end
  end

  test 'Admin: destroy should handle show not found' do
    login_as_admin

    delete :destroy, params: { id: 'nope', format: :json }
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: destroy should handle exception' do
    admin = login_as_admin

    Show.stubs(:find).raises(Exception.new("Random Exception"))

    delete :destroy, params: { id: 'whatever', format: :json }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot destroy shows' do
    login_as_host
    show = create(:show)

    delete :destroy, params: { id: show.id.to_s, show: {}, format: :json }
    assert_response :unauthorized

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Unauthorized"], results["errors"]
  end

  test 'Guest: destroy should get redirected to login' do
    show = create(:show)

    delete :destroy, params: { id: show.id.to_s, format: :json }
    assert_redirected_to  '/users/sign_in'
  end
end
