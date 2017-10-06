require 'test_helper'

class VideosControllerTest < ActionDispatch::IntegrationTest
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
    authenticate_as_admin

    get videos_url(format: :json)
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: should get index with show_id' do
    admin = authenticate_as_admin
    show = create(:show_with_videos, video_count: 3)

    get videos_url(show_id: show.id, format: :json)
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
    admin = authenticate_as_admin
    playlist = create(:playlist_with_videos, videocount: 3)

    get videos_url(playlist_id: playlist.id, format: :json)
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
    admin = authenticate_as_admin
    show = create(:show)

    videos = 10.times.map { create(:video, parent: show) }

    get videos_url(show_id: show.id, format: :json), params: { q: { s: 'id asc'}, per_page: '3', page: '2' }
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
    admin = authenticate_as_admin
    playlist = create(:playlist)

    videos = 10.times.map { create(:video, parent: playlist) }

    get videos_url(playlist_id: playlist.id, format: :json), params: { q: { s: 'id asc'}, per_page: '3', page: '2' }
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
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    get videos_url(show_id: show.id, format: :json), params: { per_page: '-1', page: '-2' }
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Admin: cannot set page < 1 with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    get videos_url(playlist_id: playlist.id, format: :json), params: { per_page: '-1', page: '-2' }
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Admin: index should handle an exception with show_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:search).raises(Exception.new("Random Exception"))
    authenticate_as_admin
    show = create(:show)

    get videos_url(show_id: show.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: index should handle an exception with playlist_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:search).raises(Exception.new("Random Exception"))
    authenticate_as_admin
    playlist = create(:playlist)

    get videos_url(playlist_id: playlist.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: should not get index without show or playlist' do
    authenticate_as_host

    get videos_url(format: :json)
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: should get index with show_id' do
    # These videos should not show up
    user = create(:user)
    create(:show_with_videos, users: [user])

    host = authenticate_as_host
    show = create(:show_with_videos, video_count: 3, users: [host])

    get videos_url(show_id: show.id, format: :json)
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

    host = authenticate_as_host
    playlist = create(:playlist_with_videos, videocount: 3, user: host)

    get videos_url(playlist_id: playlist.id, format: :json)
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

    host = authenticate_as_host
    show = create(:show, users: [host])

    videos = 10.times.map { create(:video, parent: show) }

    get videos_url(show_id: show.id, format: :json), params: { q: { s: 'id asc'}, per_page: '3', page: '2' }
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

    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    videos = 10.times.map { create(:video, parent: playlist) }

    get videos_url(playlist_id: playlist.id, format: :json), params: { q: { s: 'id asc'}, per_page: '3', page: '2' }
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
    host = authenticate_as_host
    show = create(:show, users: [host])

    get videos_url(show_id: show.id, format: :json), params: { per_page: '-1', page: '-2' }
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Host: cannot set page < 1 with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    get videos_url(playlist_id: playlist.id, format: :json), params: { per_page: '-1', page: '-2' }
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal "1", results["page"]
    assert_equal "1", results["per_page"]
  end

  test 'Host: index should handle an exception with show_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:search).raises(Exception.new("Random Exception"))
    host = authenticate_as_host
    show = create(:show, users: [host])

    get videos_url(show_id: show.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: index should handle an exception with playlist_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:search).raises(Exception.new("Random Exception"))
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    get videos_url(playlist_id: playlist.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: index should get redirected to login' do
    get videos_url(format: :json)
    assert_response :unauthorized
  end

  ##
  # Show
  ##
  test 'Admin: should not get show without show or playlist' do
    authenticate_as_admin
    video = create(:video)

    get video_url(id: video.id, format: :json)
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: should get show for own video with show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    video = create(:video, parent: show)

    get video_url(id: video.id, show_id: show.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should get show for own video with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    video = create(:video, parent: playlist)

    get video_url(id: video.id, playlist_id: playlist.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should get show for another users video with show_id' do
    host = create_user(role_titles: [:host])
    admin = authenticate_as_admin
    show = create(:show, users: [host])

    video = create(:video, parent: show)

    get video_url(id: video.id, show_id: show.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should get show for another users video with playlist_id' do
    host = create_user(role_titles: [:host])
    admin = authenticate_as_admin
    playlist = create(:playlist, user: host)

    video = create(:video, parent: playlist)

    get video_url(id: video.id, playlist_id: playlist.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should not find nonexistant video with show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    get video_url(id: 'nope', show_id: show.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: should not find nonexistant video with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    get video_url(id: 'nope', playlist_id: playlist.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: show should handle an exception with show_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))
    admin = authenticate_as_admin
    show = create(:show, users: [admin])
    video = create(:video, parent: show)

    get video_url(id: video.id,  show_id: show.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: show should handle an exception with playlist_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)
    video = create(:video, parent: playlist)

    get video_url(id: video.id,  playlist_id: playlist.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: should not get show without show or playlist' do
    authenticate_as_host
    video = create(:video)

    get video_url(id: video.id, format: :json)
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: should get show for own video with show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])

    video = create(:video, parent: show)

    get video_url(id: video.id, show_id: show.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Host: should get show for own video with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    video = create(:video, parent: playlist)

    get video_url(id: video.id, playlist_id: playlist.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Host: should not get show for another users video with show_id' do
    user = create_user(role_titles: [:host])
    host = authenticate_as_host
    show = create(:show, users: [user])

    video = create(:video, parent: show)

    get video_url(id: video.id, show_id: show.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: should get show for another users video with playlist_id' do
    user = create_user(role_titles: [:host])
    host = authenticate_as_host
    playlist = create(:playlist, user: user)

    video = create(:video, parent: playlist)

    get video_url(id: video.id, playlist_id: playlist.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: should not find nonexistant video with show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])

    get video_url(id: 'nope', show_id: show.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: should not find nonexistant video with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    get video_url(id: 'nope', playlist_id: playlist.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: show should handle an exception with show_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))
    host = authenticate_as_host
    show = create(:show, users: [host])
    video = create(:video, parent: show)

    get video_url(id: video.id, show_id: show.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: show should handle an exception with playlist_id' do
    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))
    host = authenticate_as_host
    playlist = create(:playlist, user: host)
    video = create(:video, parent: playlist)

    get video_url(id: video.id, playlist_id: playlist.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: show should get redirected to login' do
    playlist = create(:playlist)
    video = create(:video, parent: playlist)

    get video_url(id: video.id, format: :json)
    assert_response :unauthorized
  end

  ##
  # Create
  ##
  test 'Admin: cannot create a video without show_id or playlist_id' do
    authenticate_as_admin

    post videos_url(format: :json), params: { video: {} }
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: should create a video with show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post videos_url(show_id: show.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should create a video with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post videos_url(playlist_id: playlist.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should create video for a different user with show_id' do
    admin = authenticate_as_admin
    user = create_user(role_titles: [:host])
    show = create(:show, users: [user])

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post videos_url(show_id: show.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should create video for a different user with playlist_id' do
    admin = authenticate_as_admin
    user = create_user(role_titles: [:host])
    playlist = create(:playlist, user: user)

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post videos_url(playlist_id: playlist.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Admin: should fail validation for show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    post videos_url(show_id: show.id, format: :json), params: { video: {} }
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
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    post videos_url(playlist_id: playlist.id, format: :json), params: { video: {} }
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
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    post videos_url(show_id: show.id, format: :json), params: { video: {} }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: create should handle exception for playlist_id' do
    Video.stubs(:all).raises(Exception.new("Random Exception"))
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    post videos_url(playlist_id: playlist.id, format: :json), params: { video: {} }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot create a video without show_id or playlist_id' do
    authenticate_as_host

    post videos_url(format: :json), params: { video: {} }
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: should create a video with show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post videos_url(show_id: show.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Host: should create a video with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post videos_url(playlist_id: playlist.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.where(title: 'Title').first
    assert_equal JSON.parse(video.to_json), results["data"]
  end

  test 'Host: cannot create video for a different user with show_id' do
    host = authenticate_as_host
    user = create_user(role_titles: [:host])
    show = create(:show, users: [user])

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post videos_url(show_id: show.id, format: :json), params: { video: video_params }
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: cannot create video for a different user with playlist_id' do
    host = authenticate_as_host
    user = create_user(role_titles: [:host])
    playlist = create(:playlist, user: user)

    video_params = {
      title: 'Title',
      link: 'http://example.com/'
    }
    post videos_url(playlist_id: playlist.id, format: :json), params: { video: video_params }
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: should fail validation for show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])

    post videos_url(show_id: show.id, format: :json), params: { video: {} }
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
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    post videos_url(playlist_id: playlist.id, format: :json), params: { video: {} }
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
    host = authenticate_as_host
    show = create(:show, users: [host])

    post videos_url(show_id: show.id, format: :json), params: { video: {} }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: create should handle exception for playlist_id' do
    Video.stubs(:all).raises(Exception.new("Random Exception"))
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    post videos_url(playlist_id: playlist.id, format: :json), params: { video: {} }
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: create should get redirected to login' do
    post videos_url(format: :json), params: { video: {} }
    assert_response :unauthorized
  end

  ##
  # Update
  ##
  test 'Admin: cannot update show without show_id or playlist_id' do
    admin = authenticate_as_admin
    video = create(:video)

    put video_url(id: video.id, format: :json), params: { video: {} }

    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: should update video with show_id' do
    admin = authenticate_as_admin

    show = create(:show, users: [admin])
    video = create(:video, parent: show, title: 'Original Title', link: "http://localhost/videoid")

    video_params = {
      title: "Updated Title",
      link: "https://updatedurl.com/video"
    }
    put video_url(id: video.id, show_id: show.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.find(video.id)
    assert_equal JSON.parse(video.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal "https://updatedurl.com/video", results["data"]["link"]
  end

  test 'Admin: should update video with playlist_id' do
    admin = authenticate_as_admin

    playlist = create(:playlist, user: admin)
    video = create(:video, parent: playlist, title: 'Original Title', link: "http://localhost/videoid")

    video_params = {
      title: "Updated Title",
      link: "https://updatedurl.com/video"
    }
    put video_url(id: video.id, playlist_id: playlist.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.find(video.id)
    assert_equal JSON.parse(video.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal "https://updatedurl.com/video", results["data"]["link"]
  end

  test 'Admin: update should handle video not found with  show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    put video_url(id: 'nope', show_id: show.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: update should handle video not found with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    put video_url(id: 'nope', playlist_id: playlist.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: update should handle exception with show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    put video_url(id: 'whatever', show_id: show.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: update should handle exception with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    put video_url(id: 'whatever', playlist_id: playlist.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot update show without show_id or playlist_id' do
    host = authenticate_as_host
    video = create(:video)

    put video_url(id: video.id, format: :json), params: { video: {} }

    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: should update video with show_id' do
    host = authenticate_as_host

    show = create(:show, users: [host])
    video = create(:video, parent: show, title: 'Original Title', link: "http://localhost/videoid")

    video_params = {
      title: "Updated Title",
      link: "https://updatedurl.com/video"
    }
    put video_url(id: video.id, show_id: show.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.find(video.id)
    assert_equal JSON.parse(video.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal "https://updatedurl.com/video", results["data"]["link"]
  end

  test 'Host: should update video with playlist_id' do
    host = authenticate_as_host

    playlist = create(:playlist, user: host)
    video = create(:video, parent: playlist, title: 'Original Title', link: "http://localhost/videoid")

    video_params = {
      title: "Updated Title",
      link: "https://updatedurl.com/video"
    }
    put video_url(id: video.id, playlist_id: playlist.id, format: :json), params: { video: video_params }
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    video = Video.find(video.id)
    assert_equal JSON.parse(video.to_json), results["data"]

    assert_equal "Updated Title", results["data"]["title"]
    assert_equal "https://updatedurl.com/video", results["data"]["link"]
  end

  test 'Host: update should handle video not found with  show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])

    put video_url(id: 'nope', show_id: show.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: update should handle video not found with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    put video_url(id: 'nope', playlist_id: playlist.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: update should handle exception with show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    put video_url(id: 'whatever', show_id: show.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: update should handle exception with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    put video_url(id: 'whatever', playlist_id: playlist.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: update should get redirected to login' do
    video = create(:video)

    put video_url(id: video.id, format: :json)
    assert_response :unauthorized
  end

  ##
  # Destroy
  ##
  test 'Admin: cannot delete without show_id or playlist_id' do
    authenticate_as_admin
    video = create(:video)

    delete video_url(id: video.id, format: :json)
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Admin: can delete a video with show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])
    video = create(:video, parent: show)

    delete video_url(id: video.id, show_id: show.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Video.find(video.id)
    end
  end

  test 'Admin: can delete a video with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)
    video = create(:video, parent: playlist)

    delete video_url(id: video.id, playlist_id: playlist.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Video.find(video.id)
    end
  end

  test 'Admin: destroy should handle video not found with show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    delete video_url(id: 'nope', show_id: show.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: destroy should handle video not found with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    delete video_url(id: 'nope', playlist_id: playlist.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Admin: destroy should handle exception with show_id' do
    admin = authenticate_as_admin
    show = create(:show, users: [admin])

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    delete video_url(id: 'whatever', show_id: show.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Admin: destroy should handle exception with playlist_id' do
    admin = authenticate_as_admin
    playlist = create(:playlist, user: admin)

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    delete video_url(id: 'whatever', playlist_id: playlist.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: cannot delete without show_id or playlist_id' do
    authenticate_as_host
    video = create(:video)

    delete video_url(id: video.id, format: :json)
    assert_response :expectation_failed

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ['Expected Show or Playlist to be provided'], results["errors"]
  end

  test 'Host: can delete a video with show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])
    video = create(:video, parent: show)

    delete video_url(id: video.id, show_id: show.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Video.find(video.id)
    end
  end

  test 'Host: can delete a video with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)
    video = create(:video, parent: playlist)

    delete video_url(id: video.id, playlist_id: playlist.id, format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal({}, results["data"])

    assert_raise ActiveRecord::RecordNotFound do
      Video.find(video.id)
    end
  end

  test 'Host: destroy should handle video not found with show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])

    delete video_url(id: 'nope', show_id: show.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: destroy should handle video not found with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    delete video_url(id: 'nope', playlist_id: playlist.id, format: :json)
    assert_response :not_found

    results = JSON.parse(response.body)
    assert_not_empty results

    assert_equal ["Not Found"], results["errors"]
  end

  test 'Host: destroy should handle exception with show_id' do
    host = authenticate_as_host
    show = create(:show, users: [host])

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    delete video_url(id: 'whatever', show_id: show.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: destroy should handle exception with playlist_id' do
    host = authenticate_as_host
    playlist = create(:playlist, user: host)

    Video::ActiveRecord_Associations_CollectionProxy.any_instance.stubs(:find).raises(Exception.new("Random Exception"))

    delete video_url(id: 'whatever', playlist_id: playlist.id, format: :json)
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: destroy should get redirected to login' do
    video = create(:video)

    delete video_url(id: video.id, format: :json)
    assert_response :unauthorized
  end
end
