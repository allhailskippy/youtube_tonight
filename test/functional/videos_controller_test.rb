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
  test 'Admin: should not get index without show or playlist' do
    login_as_admin

    get :index, format: :json
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: should get index with show_id' do
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

  test 'Admin: should get index with playlist_id' do
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

  test 'Admin: cannot set page < 1 with show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    get :index, show_id: show.id.to_s, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Admin: cannot set page < 1 with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    get :index, playlist_id: playlist.id.to_s, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
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

  test 'Host: should not get index without show or playlist' do
    login_as_host

    get :index, format: :json
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: should get index with show_id' do
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

  test 'Host: should get index with playlist_id' do
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

  test 'Host: cannot set page < 1 with show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    get :index, show_id: show.id.to_s, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Host: cannot set page < 1 with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    get :index, playlist_id: playlist.id.to_s, format: :json, per_page: '-1', page: '-2'
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
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

  ##
  # Show
  ##
  test 'Admin: should not get show without show or playlist' do
    login_as_admin
    video = create(:video)

    get :show, id: video.id.to_s, format: :json
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: should get show for own video with show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    video = create(:video, parent: show)

    get :show, show_id: show.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should get show for own video with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    video = create(:video, parent: playlist)

    get :show, playlist_id: playlist.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should get show for another users video with show_id' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin
    show = create(:show, users: [host])

    video = create(:video, parent: show)

    get :show, show_id: show.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should get show for another users video with playlist_id' do
    host = create_user(role_titles: [:host])
    admin = login_as_admin
    playlist = create(:playlist, user: host)

    video = create(:video, parent: playlist)

    get :show, playlist_id: playlist.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should not find nonexistant video with show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    get :show, show_id: show.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: should not find nonexistant video with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    get :show, playlist_id: playlist.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: show should handle an exception with show_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))
    admin = login_as_admin
    show = create(:show, users: [admin])
    video = create(:video, parent: show)

    get :show, show_id: show.id.to_s, id: video.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: show should handle an exception with playlist_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))
    admin = login_as_admin
    playlist = create(:playlist, user: admin)
    video = create(:video, parent: playlist)

    get :show, playlist_id: playlist.id.to_s, id: video.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: should not get show without show or playlist' do
    login_as_host
    video = create(:video)

    get :show, id: video.id.to_s, format: :json
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: should get show for own video with show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    video = create(:video, parent: show)

    get :show, show_id: show.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Host: should get show for own video with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    video = create(:video, parent: playlist)

    get :show, playlist_id: playlist.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Host: should not get show for another users video with show_id' do
    user = create_user(role_titles: [:host])
    host = login_as_host
    show = create(:show, users: [user])

    video = create(:video, parent: show)

    get :show, show_id: show.id.to_s, id: video.id.to_s, format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: should get show for another users video with playlist_id' do
    user = create_user(role_titles: [:host])
    host = login_as_host
    playlist = create(:playlist, user: user)

    video = create(:video, parent: playlist)

    get :show, playlist_id: playlist.id.to_s, id: video.id.to_s, format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: should not find nonexistant video with show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    get :show, show_id: show.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: should not find nonexistant video with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    get :show, playlist_id: playlist.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: show should handle an exception with show_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))
    host = login_as_host
    show = create(:show, users: [host])
    video = create(:video, parent: show)

    get :show, show_id: show.id.to_s, id: video.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: show should handle an exception with playlist_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))
    host = login_as_host
    playlist = create(:playlist, user: host)
    video = create(:video, parent: playlist)

    get :show, playlist_id: playlist.id.to_s, id: video.id.to_s, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: show should get redirected to login' do
    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Create
  ##
  test 'Admin: cannot create a video without show_id or playlist_id' do
    login_as_admin

    post :create, video: {}, format: :json
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: should create a video with show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post :create, show_id: show.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should create a video with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post :create, playlist_id: playlist.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should create video for a different user with show_id' do
    admin = login_as_admin
    user = create_user(role_titles: [:host])
    show = create(:show, users: [user])

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post :create, show_id: show.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should create video for a different user with playlist_id' do
    admin = login_as_admin
    user = create_user(role_titles: [:host])
    playlist = create(:playlist, user: user)

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post :create, playlist_id: playlist.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should fail validation for show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    post :create, show_id: show.id.to_s, video: {}, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_not_empty results

    errors = [
      "Title can't be blank",
      "Link can't be blank",
      "Link is not a valid URL"
    ]
    errors.each do |error|
      assert results["full_errors"].include?(error)
    end
    assert_equal 3, results["full_errors"].length

    assert_equal ["can't be blank"], results["errors"]["title"]
    assert_equal ["can't be blank", "is not a valid URL"], results["errors"]["link"]
  end

  test 'Admin: should fail validation for playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    post :create, playlist_id: playlist.id.to_s, video: {}, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_not_empty results

    errors = [
      "Title can't be blank",
      "Link can't be blank",
      "Link is not a valid URL"
    ]
    errors.each do |error|
      assert results["full_errors"].include?(error)
    end
    assert_equal 3, results["full_errors"].length

    assert_equal ["can't be blank"], results["errors"]["title"]
    assert_equal ["can't be blank", "is not a valid URL"], results["errors"]["link"]
  end

  test 'Admin: create should handle exception for show_id' do
    Video.stubs(:all).raises(Exception.new("Random Exception"))
    admin = login_as_admin
    show = create(:show, users: [admin])

    post :create, show_id: show.id.to_s, video: {}, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: create should handle exception for playlist_id' do
    Video.stubs(:all).raises(Exception.new("Random Exception"))
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    post :create, playlist_id: playlist.id.to_s, video: {}, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot create a video without show_id or playlist_id' do
    login_as_host

    post :create, video: {}, format: :json
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: should create a video with show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post :create, show_id: show.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Host: should create a video with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post :create, playlist_id: playlist.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Host: cannot create video for a different user with show_id' do
    host = login_as_host
    user = create_user(role_titles: [:host])
    show = create(:show, users: [user])

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post :create, show_id: show.id.to_s, video: video_params, format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: cannot create video for a different user with playlist_id' do
    host = login_as_host
    user = create_user(role_titles: [:host])
    playlist = create(:playlist, user: user)

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post :create, playlist_id: playlist.id.to_s, video: video_params, format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: should fail validation for show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    post :create, show_id: show.id.to_s, video: {}, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_not_empty results

    errors = [
      "Title can't be blank",
      "Link can't be blank",
      "Link is not a valid URL"
    ]
    errors.each do |error|
      assert results["full_errors"].include?(error)
    end
    assert_equal 3, results["full_errors"].length

    assert_equal ["can't be blank"], results["errors"]["title"]
    assert_equal ["can't be blank", "is not a valid URL"], results["errors"]["link"]
  end

  test 'Host: should fail validation for playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    post :create, playlist_id: playlist.id.to_s, video: {}, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_not_empty results

    errors = [
      "Title can't be blank",
      "Link can't be blank",
      "Link is not a valid URL"
    ]
    errors.each do |error|
      assert results["full_errors"].include?(error)
    end
    assert_equal 3, results["full_errors"].length

    assert_equal ["can't be blank"], results["errors"]["title"]
    assert_equal ["can't be blank", "is not a valid URL"], results["errors"]["link"]
  end

  test 'Host: create should handle exception for show_id' do
    Video.stubs(:all).raises(Exception.new("Random Exception"))
    host = login_as_host
    show = create(:show, users: [host])

    post :create, show_id: show.id.to_s, video: {}, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: create should handle exception for playlist_id' do
    Video.stubs(:all).raises(Exception.new("Random Exception"))
    host = login_as_host
    playlist = create(:playlist, user: host)

    post :create, playlist_id: playlist.id.to_s, video: {}, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: create should get redirected to login' do
    post :create, video: {}, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Update
  ##
  test 'Admin: cannot update show without show_id or playlist_id' do
    admin = login_as_admin
    video = create(:video)

    put :update, id: video.id.to_s, video: {}, format: :json

    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: should update video with show_id' do
    admin = login_as_admin

    show = create(:show, users: [admin])
    video = create(:video, parent: show, title: 'Original Title', link: "http://localhost/videoid")

    video_params = {
      title: "Updated Title",
      link: "https://updatedurl.com/video"
    }
    put :update, show_id: show.id.to_s, id: video.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.find(video.id)
    assert_equal JSON.parse(video.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal "https://updatedurl.com/video", results["data"]["link"]
  end

  test 'Admin: should update video with playlist_id' do
    admin = login_as_admin

    playlist = create(:playlist, user: admin)
    video = create(:video, parent: playlist, title: 'Original Title', link: "http://localhost/videoid")

    video_params = {
      title: "Updated Title",
      link: "https://updatedurl.com/video"
    }
    put :update, playlist_id: playlist.id.to_s, id: video.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.find(video.id)
    assert_equal JSON.parse(video.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal "https://updatedurl.com/video", results["data"]["link"]
  end

  test 'Admin: update should handle video not found with  show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    put :update, show_id: show.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: update should handle video not found with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    put :update, playlist_id: playlist.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: update should handle exception with show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    put :update, show_id: show.id.to_s, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: update should handle exception with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    put :update, playlist_id: playlist.id.to_s, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot update show without show_id or playlist_id' do
    host = login_as_host
    video = create(:video)

    put :update, id: video.id.to_s, video: {}, format: :json

    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: should update video with show_id' do
    host = login_as_host

    show = create(:show, users: [host])
    video = create(:video, parent: show, title: 'Original Title', link: "http://localhost/videoid")

    video_params = {
      title: "Updated Title",
      link: "https://updatedurl.com/video"
    }
    put :update, show_id: show.id.to_s, id: video.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.find(video.id)
    assert_equal JSON.parse(video.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal "https://updatedurl.com/video", results["data"]["link"]
  end

  test 'Host: should update video with playlist_id' do
    host = login_as_host

    playlist = create(:playlist, user: host)
    video = create(:video, parent: playlist, title: 'Original Title', link: "http://localhost/videoid")

    video_params = {
      title: "Updated Title",
      link: "https://updatedurl.com/video"
    }
    put :update, playlist_id: playlist.id.to_s, id: video.id.to_s, video: video_params, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.find(video.id)
    assert_equal JSON.parse(video.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal "https://updatedurl.com/video", results["data"]["link"]
  end

  test 'Host: update should handle video not found with  show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    put :update, show_id: show.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: update should handle video not found with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    put :update, playlist_id: playlist.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: update should handle exception with show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    put :update, show_id: show.id.to_s, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: update should handle exception with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    put :update, playlist_id: playlist.id.to_s, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: update should get redirected to login' do
    video = create(:video)

    put :update, id: video.id.to_s, format: :json
    assert_redirected_to  '/users/sign_in'
  end

  ##
  # Destroy
  ##
  test 'Admin: cannot delete without show_id or playlist_id' do
    login_as_admin
    video = create(:video)

    delete :destroy, id: video.id.to_s, format: :json
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: can delete a video with show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])
    video = create(:video, parent: show)

    delete :destroy, show_id: show.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Video.find(video.id)
    end
  end

  test 'Admin: can delete a video with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)
    video = create(:video, parent: playlist)

    delete :destroy, playlist_id: playlist.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Video.find(video.id)
    end
  end

  test 'Admin: destroy should handle video not found with show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    delete :destroy, show_id: show.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: destroy should handle video not found with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    delete :destroy, playlist_id: playlist.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: destroy should handle exception with show_id' do
    admin = login_as_admin
    show = create(:show, users: [admin])

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    delete :destroy, show_id: show.id.to_s, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: destroy should handle exception with playlist_id' do
    admin = login_as_admin
    playlist = create(:playlist, user: admin)

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    delete :destroy, playlist_id: playlist.id.to_s, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot delete without show_id or playlist_id' do
    login_as_host
    video = create(:video)

    delete :destroy, id: video.id.to_s, format: :json
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: can delete a video with show_id' do
    host = login_as_host
    show = create(:show, users: [host])
    video = create(:video, parent: show)

    delete :destroy, show_id: show.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Video.find(video.id)
    end
  end

  test 'Host: can delete a video with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)
    video = create(:video, parent: playlist)

    delete :destroy, playlist_id: playlist.id.to_s, id: video.id.to_s, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Video.find(video.id)
    end
  end

  test 'Host: destroy should handle video not found with show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    delete :destroy, show_id: show.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: destroy should handle video not found with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    delete :destroy, playlist_id: playlist.id.to_s, id: 'nope', format: :json
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: destroy should handle exception with show_id' do
    host = login_as_host
    show = create(:show, users: [host])

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    delete :destroy, show_id: show.id.to_s, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: destroy should handle exception with playlist_id' do
    host = login_as_host
    playlist = create(:playlist, user: host)

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    delete :destroy, playlist_id: playlist.id.to_s, id: 'whatever', format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: destroy should get redirected to login' do
    video = create(:video)

    delete :destroy, id: video.id.to_s, format: :json
    assert_redirected_to  '/users/sign_in'
  end
end
