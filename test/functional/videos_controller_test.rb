class VideosControllerTest < ActionController::TestCase
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing('/videos.json', controller: 'videos', action: 'index', format: 'json')
    assert_routing('/videos/1.json', controller: 'videos', action: 'show', id: '1', format: 'json')
    assert_routing({ method: 'post', path: '/videos.json'}, { controller: 'videos', action: 'create', format: 'json' })
    assert_routing({ method: 'put', path: '/videos/1.json'}, { controller: 'videos', action: 'update', id: '1', format: 'json'})
    assert_routing({ method: 'delete', path: '/videos/1.json'}, { controller: 'videos', action: 'destroy', id: '1', format: 'json'})
  end

  ##
  # Index
  ##
  test 'Admin: should get index videos' do
    admin = login_as_admin

    v1 = without_access_control { create(:video) }
    v2 = without_access_control { create(:video) }
    v3 = without_access_control { create(:video) }

    get :index, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all videos
    assert_equal 3, results["data"].length
    expected = [
      JSON.parse(v3.to_json),
      JSON.parse(v2.to_json),
      JSON.parse(v1.to_json)
    ]
    assert_equal expected, results["data"]

    # Pagination
    assert_equal '1', results["page"]
    assert_equal '10', results["per_page"]
    assert_equal 3, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]
  end

  test 'Admin: should get index videos with show_id' do
    admin = login_as_admin
    show = create(:show_with_videos, video_count: 3)

    get :index, show_id: show.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all videos
    assert_equal 3, results["data"].length
    expected = [
      JSON.parse(show.videos[2].to_json),
      JSON.parse(show.videos[1].to_json),
      JSON.parse(show.videos[0].to_json)
    ]
    assert_equal expected, results["data"]

    # Pagination
    assert_equal '1', results["page"]
    assert_equal '10', results["per_page"]
    assert_equal 3, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]
  end

  test 'Admin: should get index videos with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist_with_videos, videocount: 3)

    get :index, playlist_id: playlist.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all videos
    assert_equal 3, results["data"].length
    expected = [
      JSON.parse(playlist.videos[2].to_json),
      JSON.parse(playlist.videos[1].to_json),
      JSON.parse(playlist.videos[0].to_json)
    ]
    assert_equal expected, results["data"]

    # Pagination
    assert_equal '1', results["page"]
    assert_equal '10', results["per_page"]
    assert_equal 3, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]
  end

  test 'Admin: should get index with custom params' do
    admin = login_as_admin

    videos = without_access_control { 10.times.map { create(:video) } }

    get :index, format: :json, q: { s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 10, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all videos for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(videos[3].to_json),
      JSON.parse(videos[4].to_json),
      JSON.parse(videos[5].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Admin: should get index with custom params with show_id' do
    admin = login_as_admin
    show = create(:show)

    videos = without_access_control { 10.times.map { create(:video, parent: show) } }

    get :index, show_id: show.id.to_s, format: :json, q: { s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 10, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all videos for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(videos[3].to_json),
      JSON.parse(videos[4].to_json),
      JSON.parse(videos[5].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Admin: should get index with custom params with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist)

    videos = without_access_control { 10.times.map { create(:video, parent: playlist) } }

    get :index, playlist_id: playlist.id.to_s, format: :json, q: { s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 10, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all videos for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(videos[3].to_json),
      JSON.parse(videos[4].to_json),
      JSON.parse(videos[5].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Admin: cannot set page < 1' do
    admin = login_as_admin

    get :index, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Admin: cannot set page < 1 with show_id' do
    admin = login_as_admin
    show = create(:show)

    get :index, id: show.id.to_s, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Admin: cannot set page < 1 with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist)

    get :index, id: playlist.id.to_s, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Admin: index should handle an exception' do
    Video.stubs(:with_permissions_to).raises(Exception.new("Random Exception"))
    login_as_admin

    get :index, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: index should handle an exception with show_id' do
    Video.stubs(:with_permissions_to).raises(Exception.new("Random Exception"))
    login_as_admin
    show = create(:show)

    get :index, show_id: show.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: index should handle an exception with playlist_id' do
    Video.stubs(:with_permissions_to).raises(Exception.new("Random Exception"))
    login_as_admin
    playlist = create(:playlist)

    get :index, playlist_id: playlist.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: should get index' do
    host = login_as_host

    v1 = create(:video)
    v2 = create(:video)
    v3 = create(:video)

    get :index, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all videos
    assert_equal 3, results["data"].length
    expected = [
      JSON.parse(v3.to_json),
      JSON.parse(v2.to_json),
      JSON.parse(v1.to_json)
    ]
    assert_equal expected, results["data"]

    # Pagination
    assert_equal '1', results["page"]
    assert_equal '10', results["per_page"]
    assert_equal 3, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]
  end

  test 'Host: should get index videos with show_id' do
    # These videos should not show up
    user = create(:user)
    create(:show_with_videos, users: [user])

    host = login_as_host
    show = create(:show_with_videos, video_count: 3, users: [host])

    get :index, show_id: show.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all videos
    assert_equal 3, results["data"].length
    expected = [
      JSON.parse(show.videos[2].to_json),
      JSON.parse(show.videos[1].to_json),
      JSON.parse(show.videos[0].to_json)
    ]
    assert_equal expected, results["data"]

    # Pagination
    assert_equal '1', results["page"]
    assert_equal '10', results["per_page"]
    assert_equal 3, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]
  end

  test 'Host: should get index videos with playlist_id' do
    # These videos should not show up
    user = create(:user)
    create(:playlist_with_videos, user: user)

    host = login_as_host
    playlist = create(:playlist_with_videos, videocount: 3, user: host)

    get :index, playlist_id: playlist.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Gets all videos
    assert_equal 3, results["data"].length
    expected = [
      JSON.parse(playlist.videos[2].to_json),
      JSON.parse(playlist.videos[1].to_json),
      JSON.parse(playlist.videos[0].to_json)
    ]
    assert_equal expected, results["data"]

    # Pagination
    assert_equal '1', results["page"]
    assert_equal '10', results["per_page"]
    assert_equal 3, results["total"]
    assert_equal 1, results["total_pages"]
    assert_equal 0, results["offset"]
  end

  test 'Host: should get index with custom params' do
    host = login_as_host

    videos = without_access_control { 10.times.map { create(:video) } }

    get :index, format: :json, q: { s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 10, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all videos for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(videos[3].to_json),
      JSON.parse(videos[4].to_json),
      JSON.parse(videos[5].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Host: should get index with custom params with show_id' do
    # These videos should not show up
    user = create(:user)
    create(:show_with_videos, users: [user])

    host = login_as_host
    show = create(:show, users: [host])

    videos = 10.times.map { create(:video, parent: show) }

    get :index, show_id: show.id.to_s, format: :json, q: { s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 10, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all videos for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(videos[3].to_json),
      JSON.parse(videos[4].to_json),
      JSON.parse(videos[5].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Host: should get index with custom params with playlist_id' do
    # These videos should not show up
    user = create(:user)
    create(:playlist_with_videos, user: user)

    host = login_as_host
    playlist = create(:playlist, user: host)

    videos = 10.times.map { create(:video, parent: playlist) }

    get :index, playlist_id: playlist.id.to_s, format: :json, q: { s: 'id asc'}, per_page: '3', page: '2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    # Pagination
    assert_equal '2', results["page"]
    assert_equal '3', results["per_page"]
    assert_equal 10, results["total"]
    assert_equal 4, results["total_pages"]
    assert_equal 3, results["offset"]

    # Gets all videos for host user
    assert_equal 3, results["data"].length

    expected = [
      JSON.parse(videos[3].to_json),
      JSON.parse(videos[4].to_json),
      JSON.parse(videos[5].to_json)
    ]
    assert_equal expected, results["data"]
  end

  test 'Host: cannot set page < 1' do
    host = login_as_host

    get :index, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Host: cannot set page < 1 with show_id' do
    host = login_as_host
    show = create(:show)

    get :index, id: show.id.to_s, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Host: cannot set page < 1 with playlist_id' do
    hsot = login_as_host
    playlist = create(:playlist)

    get :index, id: playlist.id.to_s, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Host: index should handle an exception' do
    Video.stubs(:with_permissions_to).raises(Exception.new("Random Exception"))
    login_as_host

    get :index, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: index should handle an exception with show_id' do
    Video.stubs(:with_permissions_to).raises(Exception.new("Random Exception"))
    host = login_as_host
    show = create(:show, users: [host])

    get :index, show_id: show.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: index should handle an exception with playlist_id' do
    Video.stubs(:with_permissions_to).raises(Exception.new("Random Exception"))
    host = login_as_host
    playlist = create(:playlist, user: host)

    get :index, playlist_id: playlist.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: index should get redirected to login' do
    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end
#
#  ##
#  # Show
#  ##
#  test 'Admin: should get show for own video' do
#    admin = login_as_admin
#
#    s1 = without_access_control { create(:video, users: [admin]) }
#
#    get :show, id: s1.id.to_s, format: :json
#    assert_response :success
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal JSON.parse(s1.to_json), results["data"]
#  end
#
#  test 'Admin: should get show for another users video' do
#    host = create_user(role_titles: [:host])
#    admin = login_as_admin
#
#    s1 = without_access_control { create(:video, users: [host]) }
#
#    get :show, id: s1.id.to_s, format: :json
#    assert_response :success
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal JSON.parse(s1.to_json), results["data"]
#  end
#
#  test 'Admin: should not find nonexistant video' do
#    login_as_admin
#
#    get :show, id: 'nope', format: :json
#    assert_response :not_found
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal ["Not Found"], results["errors"]
#  end
#
#  test 'Admin: show should handle an exception' do
#    Video.stubs(:find).raises(Exception.new("Random Exception"))
#    admin = login_as_admin
#
#    get :show, id: 'whatever', format: :json
#    assert_response :unprocessable_entity
#
#    results = JSON.parse(response.body)
#    assert_equal ["Random Exception"], results["errors"]
#  end
#
#  test 'Host: should get show for own video' do
#    host = login_as_host
#
#    p1 = without_access_control { create(:video, users: [host]) }
#
#    get :show, id: p1.id.to_s, format: :json
#    assert_response :success
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal JSON.parse(p1.to_json), results["data"]
#  end
#
#  test 'Host: should not get show for another users video' do
#    user = create_user(role_titles: [:host])
#    host = login_as_host
#
#    p1 = without_access_control { create(:video, users: [user]) }
#
#    get :show, id: p1.id.to_s, format: :json
#    assert_response :unauthorized
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal ["Unauthorized"], results["errors"]
#  end
#
#  test 'Host: should not find nonexistant video' do
#    login_as_host
#
#    get :show, id: 'nope', format: :json
#    assert_response :not_found
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal ["Not Found"], results["errors"]
#  end
#
#  test 'Host: show should handle an exception' do
#    Video.stubs(:find).raises(Exception.new("Random Exception"))
#    host = login_as_host
#
#    get :show, id: 'whatever', format: :json
#    assert_response :unprocessable_entity
#
#    results = JSON.parse(response.body)
#    assert_equal ["Random Exception"], results["errors"]
#  end
#
#  test 'Guest: show should get redirected to login' do
#    get :index, format: :json
#    assert_redirected_to  '/users/sign_in'
#  end
#
#  ##
#  # Create
#  ##
#  test 'Admin: should create a video' do
#    admin = login_as_admin
#    user = create_user(role_titles: [:host])
#
#    video_params = {
#      air_date: Date.today.to_s(:db),
#      title: 'Created Title',
#      hosts: [admin.id, user.id].join(',')
#    }
#
#    post :create, video: video_params, format: :json
#    assert_response :success
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    video = Video.where(title: 'Created Title').first
#    assert_equal JSON.parse(video.to_json), results["data"]
#  end
#
#  test 'Admin: should create video for a different user' do
#    admin = login_as_admin
#    user = create_user(role_titles: [:host])
#
#    show_params = {
#      air_date: Date.today.to_s(:db),
#      title: 'Created Title',
#      hosts: user.id.to_s
#    }
#
#    post :create, show: show_params, format: :json
#    assert_response :success
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    show = Video.where(title: 'Created Title').first
#    assert_equal JSON.parse(show.to_json), results["data"]
#  end
#
#  test 'Admin: should fail validation' do
#    admin = login_as_admin
#
#    post :create, show: {}, format: :json
#    assert_response :unprocessable_entity
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    errors = [
#      "Title can't be blank",
#      "Air date is not a date",
#      "Host must be selected"
#    ]
#    errors.each do |error|
#      assert results["full_errors"].include?(error)
#    end
#    assert_equal 3, results["full_errors"].length
#
#    assert_equal ["can't be blank"], results["errors"]["title"]
#    assert_equal ["must be selected"], results["errors"]["hosts"]
#    assert_equal ["is not a date"], results["errors"]["air_date"]
#  end
#
#  test 'Admin: create should handle exception' do
#    Video.stubs(:all).raises(Exception.new("Random Exception"))
#    login_as_admin
#
#    post :create, show: {}, format: :json
#    assert_response :unprocessable_entity
#
#    results = JSON.parse(response.body)
#    assert_equal ["Random Exception"], results["errors"]
#  end
#
#  test 'Host: cannot create videos' do
#    login_as_host
#
#    post :create, show: {}, format: :json
#    assert_redirected_to  '/users/sign_in'
#  end
#
#  test 'Guest: create should get redirected to login' do
#    post :create, show: {}, format: :json
#    assert_redirected_to  '/users/sign_in'
#  end
#
#  ##
#  # Update
#  ##
#  test 'Admin: should update show' do
#    admin = login_as_admin
#    user = create_user(role_titles: [:host])
#
#    show = create(:video, users: [admin], title: 'Original Title', air_date: Date.today.to_s(:db))
#    show_params = {
#      title: "Updated Title",
#      air_date: Date.tomorrow.to_s(:db),
#      hosts: user.id.to_s
#    }
#    put :update, id: show.id.to_s, show: show_params, format: :json
#    assert_response :success
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    show = Video.find(show.id)
#    assert_equal JSON.parse(show.to_json), results["data"]
#
#    assert_equal "Updated Title", results["data"]["title"]
#    assert_equal Date.tomorrow.to_s(:db), results["data"]["air_date"]
#    assert_equal user.id.to_s, results["data"]["hosts"]
#  end
#
#  test 'Admin: update should handle show not found' do
#    login_as_admin
#
#    put :update, id: 'nope', format: :json
#    assert_response :not_found
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal ["Not Found"], results["errors"]
#  end
#
#  test 'Admin: update should handle exception' do
#    admin = login_as_admin
#
#    Video.stubs(:find).raises(Exception.new("Random Exception"))
#
#    put :update, id: 'whatever', format: :json
#    assert_response :unprocessable_entity
#
#    results = JSON.parse(response.body)
#    assert_equal ["Random Exception"], results["errors"]
#  end
#
#  test 'Host: cannot update videos' do
#    login_as_host
#
#    put :update, id: 'whatever', show: {}, format: :json
#    assert_redirected_to  '/users/sign_in'
#  end
#
#  test 'Guest: update should get redirected to login' do
#    show = create(:video)
#
#    put :update, id: show.id.to_s, format: :json
#    assert_redirected_to  '/users/sign_in'
#  end
#
#  ##
#  # Destroy
#  ##
#  test 'Admin: can delete a show' do
#    admin = login_as_admin
#
#    show = create(:video)
#
#    delete :destroy, id: show.id.to_s, format: :json
#    assert_response :success
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal({}, results["data"])
#
#    assert_raise ActiveRecord::RecordNotFound do
#      Video.find(show.id)
#    end
#  end
#
#  test 'Admin: destroy should handle show not found' do
#    login_as_admin
#
#    delete :destroy, id: 'nope', format: :json
#    assert_response :not_found
#
#    results = JSON.parse(response.body)
#    assert_not_empty results
#
#    assert_equal ["Not Found"], results["errors"]
#  end
#
#  test 'Admin: destroy should handle exception' do
#    admin = login_as_admin
#
#    Video.stubs(:find).raises(Exception.new("Random Exception"))
#
#    delete :destroy, id: 'whatever', format: :json
#    assert_response :unprocessable_entity
#
#    results = JSON.parse(response.body)
#    assert_equal ["Random Exception"], results["errors"]
#  end
#
#  test 'Host: cannot destroy videos' do
#    login_as_host
#
#    delete :destroy, id: 'whatever', show: {}, format: :json
#    assert_redirected_to  '/users/sign_in'
#  end
#
#  test 'Guest: destroy should get redirected to login' do
#    show = create(:video)
#
#    delete :destroy, id: show.id.to_s, format: :json
#    assert_redirected_to  '/users/sign_in'
#  end
end
