class PlaylistsControllerTest < ActionController::TestCase
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing('/playlists.json', controller: 'playlists', action: 'index', format: 'json')
    assert_routing({ method: 'post', path: '/playlists.json'}, { controller: 'playlists', action: 'create', format: 'json' })
    assert_routing('/playlists/1.json', controller: 'playlists', action: 'show', id: '1', format: 'json')
    assert_routing({ method: 'put', path: '/playlists/1.json'}, { controller: 'playlists', action: 'update', id: '1', format: 'json'})
  end

  ##
  # Index
  ##
  test 'Admin: should get index without any params' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin

    p1 = without_access_control { create(:playlist, user: admin) }
    p2 = without_access_control { create(:playlist, user: admin) }
    p3 = without_access_control { create(:playlist, user: host) }

    ##
    # With default params
    ##
    get :index, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results
    
    # Pagination
    assert_equal '1', results["page"]
    assert_equal '10', results["per_page"]
    assert_equal 2, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]

    # Gets all playlists for current user
    assert_equal 2, results["data"].length
    assert_equal [JSON.parse(p2.to_json), JSON.parse(p1.to_json)], results["data"]
  end

  test 'Admin: should get index with custom params' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin

    playlists = without_access_control { 10.times.map { create(:playlist, user: host) } }

    get :index, format: :json, q: { user_id_eq: host.id.to_s, s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results
    
    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 10, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all playlists for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(playlists[3].to_json),
      JSON.parse(playlists[4].to_json),
      JSON.parse(playlists[5].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Admin: cannot set page < 1' do
    admin = login_as_admin

    p1 = without_access_control { create(:playlist, user: admin) }

    get :index, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Host: should get index without any params' do
    admin = create_user(role_titles: [:admin])
    host2 = create_user(role_titles: [:host])
    host = login_as_host

    p1 = without_access_control { create(:playlist, user: host) }
    p2 = without_access_control { create(:playlist, user: host) }
    p3 = without_access_control { create(:playlist, user: admin) }
    p4 = without_access_control { create(:playlist, user: host2) }

    ##
    # With default params
    ##
    get :index, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results
    
    # Pagination
    assert_equal '1', results["page"]
    assert_equal '10', results["per_page"]
    assert_equal 2, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]

    # Gets all playlists for current user
    assert_equal 2, results["data"].length
    assert_equal [JSON.parse(p2.to_json), JSON.parse(p1.to_json)], results["data"]
  end

  test "Host: cannot see other users playlists" do
    host2 = create_user(role_titles: [:host])
    host = login_as_host
    playlists = without_access_control { 10.times.map { create(:playlist, user: host2) } }

    get :index, format: :json, q: { user_id_eq: host2.id.to_s }
    assert_response :success

    results = JSON.parse(response.body)

    # Gets no playlists for host2 user
    assert_equal 0, results["data"].length
    assert_equal 0, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]
  end

  test 'Host: should get index with custom params' do
    host2 = create_user(role_titles: [:host])
    host = login_as_host

    playlists = without_access_control { 10.times.map { create(:playlist, user: host) } }

    get :index, format: :json, q: { user_id_eq: host.id.to_s, s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results
    
    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 10, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all playlists for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(playlists[3].to_json),
      JSON.parse(playlists[4].to_json),
      JSON.parse(playlists[5].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Host: cannot set page < 1' do
    host = login_as_host

    p1 = without_access_control { create(:playlist, user: host) }

    get :index, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Guest: should get redirected to login' do
    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end
end
