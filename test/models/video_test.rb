require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  test 'model stamper' do
    stamp = create(:user)
    User.stamper = stamp
    video = create(:video)

    assert_equal stamp, video.creator
    assert_equal stamp, video.updater
  end

  test "relationships" do
    # Belongs to parent: show
    playlist = create(:playlist)
    video = create(:video, parent: playlist)
    assert_equal playlist, video.parent

    show = create(:show)
    video = create(:video, parent: show)
    assert_equal show, video.parent
  end

  test 'validation' do
    # On create
    video = Video.new
    assert !video.valid?
    assert_equal ["can't be blank"], video.errors.messages[:title]
    assert_equal 2, video.errors.messages[:link].size
    assert video.errors.messages[:link].include?("can't be blank")
    assert video.errors.messages[:link].include?("is not a valid URL")

    # start and end time validations
    video.start_time = 100
    video.end_time = 50
    video.api_duration_seconds = 10
    assert !video.valid?
    assert_equal 2, video.errors.messages[:base].length
    assert video.errors.messages[:base].include?("Start At cannot be greater than End At")
    assert video.errors.messages[:base].include?("End At cannot be longer than the video duration: 10")
  end

  test 'callbacks: set_position' do
    # Position for show
    show = create(:show)
    v1 = create(:video, parent: show)
    v2 = create(:video, parent: show)
    v3 = create(:video, parent: show)
    assert_equal 0, v1.position
    assert_equal 1, v2.position
    assert_equal 2, v3.position

    # Position for playlist
    playlist = create(:playlist)
    v1 = create(:video, parent: playlist)
    v2 = create(:video, parent: playlist)
    v3 = create(:video, parent: playlist)
    assert_equal 0, v1.position
    assert_equal 1, v2.position
    assert_equal 2, v3.position
  end

  test 'callbacks: send_video_update_request - on create' do
    ShowEventsChannel.expects(:broadcast_to).with(anything, {'action' => 'update_video_list'}).once

    show = create(:show)
    create(:video, parent: show)

    # playlist should not trigger a second call
    playlist = create(:playlist)
    create(:video, parent: playlist)
  end

  test 'callbacks: send_video_update_request - on update' do
    ShowEventsChannel.expects(:broadcast_to).with(anything, {'action' => 'update_video_list'}).twice

    # First call is for create
    show = create(:show)
    video = create(:video, parent: show)

    # Second call is for update
    video.update_attribute(:title, 'edited title')

    # playlist should not trigger a second call
    playlist = create(:playlist)
    create(:video, parent: playlist)
  end

  test 'callbacks: send_video_update_request - on destroy' do
    ShowEventsChannel.expects(:broadcast_to).with(anything, {'action' => 'update_video_list'}).twice

    # First call is for create
    show = create(:show)
    video = create(:video, parent: show)

    # Second call is for destroy
    video.destroy

    # playlist should not trigger a second call
    playlist = create(:playlist)
    create(:video, parent: playlist)
  end

  test 'is show or is playlist' do
    show = create(:show)
    video = create(:video, parent: show)
    assert video.is_show?
    assert !video.is_playlist?

    playlist = create(:playlist)
    video = create(:video, parent: playlist)
    assert !video.is_show?
    assert video.is_playlist?
  end
end
