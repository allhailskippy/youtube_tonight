class PlaylistsControllerTest < ActionController::TestCase
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing('/playlists.json', controller: 'playlists', action: 'index', format: 'json')
    assert_routing('/playlists/1.json', controller: 'playlists', action: 'show', id: '1', format: 'json')
    assert_routing({ method: 'post', path: '/playlists.json'}, { controller: 'playlists', action: 'create', format: 'json' })
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

  test 'Admin: index should handle an exception' do
    Ransack::Search.any_instance.stubs(:result).raises(Exception.new("Random Exception"))
    login_as_admin

    get :index, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal "Random Exception", results["errors"]
  end

  test 'Host: should get index without any params' do
    admin = create_user(role_titles: [:admin])
    host2 = create_user(role_titles: [:host])
    host = login_as_host

    p1 = without_access_control { create(:playlist, user: host) }
    p2 = without_access_control { create(:playlist, user: host) }
    p3 = without_access_control { create(:playlist, user: admin) }
    p4 = without_access_control { create(:playlist, user: host2) }

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

  test 'Host: index should handle an exception' do
    Ransack::Search.any_instance.stubs(:result).raises(Exception.new("Random Exception"))
    login_as_host

    get :index, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal "Random Exception", results["errors"]
  end

  test 'Guest: index should get redirected to login' do
    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Show
  ##
  test 'Admin: should get show for own playlist' do
    admin = login_as_admin

    p1 = without_access_control { create(:playlist, user: admin) }

    get :show, id: p1.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(p1.to_json), results["data"]
  end

  test 'Admin: should get show for another users playlist' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin

    p1 = without_access_control { create(:playlist, user: host) }

    get :show, id: p1.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(p1.to_json), results["data"]
  end

  test 'Admin: should not find nonexistant playlist' do
    login_as_admin

    get :show, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal "Not Found", results["errors"]
  end

  test 'Admin: show should handle an exception' do
    Playlist.stubs(:find).raises(Exception.new("Random Exception"))
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    get :show, id: playlist.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal "Random Exception", results["errors"]
  end

  test 'Host: should get show for own playlist' do
    host = login_as_host

    p1 = without_access_control { create(:playlist, user: host) }

    get :show, id: p1.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(p1.to_json), results["data"]
  end

  test 'Host: should not get show for another users playlist' do
    user = create_user(role_titles: [:host])
    host = login_as_host

    p1 = without_access_control { create(:playlist, user: user) }

    get :show, id: p1.id.to_s, format: :json
    assert_response :unauthorized

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal "Unauthorized", results["errors"]
  end

  test 'Host: should not find nonexistant playlist' do
    login_as_host

    get :show, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal "Not Found", results["errors"]
  end

  test 'Host: show should handle an exception' do
    Playlist.stubs(:find).raises(Exception.new("Random Exception"))
    host = login_as_host
    playlist = create(:playlist, user: host)

    get :show, id: playlist.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal "Random Exception", results["errors"]
  end

  test 'Guest: show should get redirected to login' do
    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Create
  ##
  test 'Admin: should create playlists for itself' do
    admin = login_as_admin

    playlist = create(:playlist, user: admin)
    User.any_instance.expects(:import_playlists).once.returns([playlist])

    post :create, format: :json
    assert_response :success


    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal [JSON.parse(playlist.to_json)], results["data"]
  end

  test 'Admin: should create playlist for a different user' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin

    playlist = create(:playlist, user: host)
    User.any_instance.expects(:import_playlists).once.returns([playlist])

    post :create, user_id: host.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal [JSON.parse(playlist.to_json)], results["data"]
  end

  test 'Admin: create should handle exception' do
    User.any_instance.stubs(:import_playlists).raises(Exception.new("Random Exception"))
    login_as_admin

    post :create, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal "Random Exception", results["errors"]
  end

  test 'Host: should create playlist for itself' do
    host = login_as_host

    playlist = create(:playlist, user: host)
    User.any_instance.expects(:import_playlists).once.returns([playlist])

    post :create, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal [JSON.parse(playlist.to_json)], results["data"]
  end

  test 'Host: cannot create playlist for a different user' do
    host2 = create_user(role_titles: [:host])
    host = login_as_host

    post :create, user_id: host2.id.to_s, format: :json
    assert_response :unauthorized
  end

  test 'Host: create should handle exception' do
    User.any_instance.stubs(:import_playlists).raises(Exception.new("Random Exception"))
    login_as_host

    post :create, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal "Random Exception", results["errors"]
  end

  test 'Guest: create should get redirected to login' do
    user = create_user(role_titles: [:admin])

    post :create, user_id: user.id.to_s, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Update
  ##
  test 'Admin: should update playlist for itself' do
    admin = login_as_admin

    playlist = create(:playlist_with_videos, user: admin)
    VideoImportWorker.expects(:perform_async).with(playlist.id).once.returns(playlist.videos)

    put :update, id: playlist.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(playlist.videos.to_json), results["data"]
  end

  test 'Admin: should update playlist for a different user' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin

    playlist = create(:playlist, user: host)
    VideoImportWorker.expects(:perform_async).with(playlist.id).once.returns(playlist.videos)

    put :update, id: playlist.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(playlist.videos.to_json), results["data"]
  end

  test 'Admin: update should handle playlist not found' do
    login_as_admin

    put :update, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal "Not Found", results["errors"]
  end

  test 'Admin: update should handle exception' do
    admin = login_as_admin

    playlist = create(:playlist, user: admin)
    VideoImportWorker.expects(:perform_async).with(playlist.id).raises(Exception.new('Random Exception'))

    put :update, id: playlist.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal "Random Exception", results["errors"]
  end

  test 'Host: should update playlist for itself' do
    host = login_as_host

    playlist = create(:playlist_with_videos, user: host)
    VideoImportWorker.expects(:perform_async).with(playlist.id).once.returns(playlist.videos)

    put :update, id: playlist.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(playlist.videos.to_json), results["data"]
  end

  test 'Host: should not be able to update playlist for a different user' do
    host = create_user(role_titles: [:host])
    login_as_host

    playlist = create(:playlist, user: host)

    put :update, id: playlist.id.to_s, format: :json
    assert_response :unauthorized

    results = JSON.parse(response.body)
    assert_equal "Unauthorized", results["errors"]
  end

  test 'Host: update should handle playlist not found' do
    login_as_host

    put :update, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal "Not Found", results["errors"]
  end

  test 'Host: update should handle exception' do
    host = login_as_host

    playlist = create(:playlist, user: host)
    VideoImportWorker.expects(:perform_async).with(playlist.id).raises(Exception.new('Random Exception'))

    put :update, id: playlist.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal "Random Exception", results["errors"]
  end

  test 'Guest: update should get redirected to login' do
    playlist = create(:playlist)

    put :update, id: playlist.id.to_s, format: :json
    assert_redirected_to  '/users/sign_in'
  end
end
