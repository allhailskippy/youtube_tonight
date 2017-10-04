class YoutubeParserControllerTest < ActionController::TestCase
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing '/youtube_parser', controller: 'youtube_parser', action: 'index'
  end

  ##
  # Index
  ##
  def stub_get_video_info
    response = {
      video_id: 'abc123',
      start_time: '0',
      end_time: nil,
      published_at: Time.now.to_s(:db),
      channel_id: 'aaaaaa',
      channel_title: 'Fake Channel',
      description: 'This is a video description',
      thumbnail_default_url: 'http://localhost/default.gif',
      thumbnail_medium_url: 'http://localhost/medium.gif',
      thumbnail_high_url: 'http://localhost/high.gif',
      title: 'Video Title',
      link: "https://www.youtube.com/v/abc123",
      duration: 'PT30S',
      duration_seconds: 30
    }
    YoutubeApi.expects(:get_video_info).returns(response)
  end

  test 'Admin: should get index' do
    stub_get_video_info

    login_as_admin

    get :index, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results
  end

  test 'Admin: should handle exception' do
    YoutubeApi.stubs(:get_video_info).raises(Exception.new("Random Exception"))

    login_as_admin

    get :index, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Host: should get index as html' do
    stub_get_video_info

    login_as_host

    get :index, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results
  end

  test 'Host: should handle exception' do
    YoutubeApi.stubs(:get_video_info).raises(Exception.new("Random Exception"))

    login_as_host

    get :index, format: :json
    assert_response :unprocessable_entity

    results = JSON.parse(response.body)
    assert_equal ["Random Exception"], results["errors"]
  end

  test 'Guest: should get index as html' do
    get :index, format: :json
    assert_redirected_to  '/users/sign_in'
  end
end
