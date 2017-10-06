require 'test_helper'

class PlaylistTest < ActiveSupport::TestCase
  test 'model stamper' do
    stamp = create(:user)
    User.stamper = stamp
    playlist = create(:playlist)

    assert_equal stamp, playlist.creator
    assert_equal stamp, playlist.updater
  end

  test "relationships" do
    # belongs to user
    user = create(:user)
    playlist = create(:playlist, user: user)
    assert_equal user, playlist.user

    # has many videos
    v1 = create(:video, parent: playlist)
    v2 = create(:video, parent: playlist)

    playlist.reload
    assert_equal 2, playlist.videos.length
    assert playlist.videos.include?(v1)
    assert playlist.videos.include?(v2)

    # Destroys related videos when deleting playlist
    assert_difference 'Video.count', -2 do
      playlist.destroy
    end
  end

  def fake_videos
    videos = [{
      'video_id': 'abc123',
      'title': 'test video',
      'thumbnail_medium_url': 'http://test.com/medium.gif',
      'thumbnail_default_url': 'http://test.com/default.gif',
      'thumbnail_high_url': 'http://test.com/high.gif',
      'duration': 'PT2M41S',
      'duration_seconds': 161,
      'channel_title': 'test channel',
      'channel_id': 'testtesttest1',
      'position': 0
    }, {
      'video_id': 'abc124',
      'title': 'test video 2',
      'thumbnail_medium_url': 'http://test.com/medium2.gif',
      'thumbnail_default_url': 'http://test.com/default2.gif',
      'thumbnail_high_url': 'http://test.com/high2.gif',
      'duration': 'PT53M32S',
      'duration_seconds': 3212,
      'channel_title': 'test channel',
      'channel_id': 'testtesttest1',
      'position': 1
    }]
  end

  test 'imports videos' do
    user = create(:user)
    playlist = create(:playlist, api_playlist_id: 'test123', user: user)

    YoutubeApi.expects(:get_videos_for_playlist).with('test123', user).returns(fake_videos)
    PlaylistEventsChannel.expects(:broadcast_to).with(user, { action: 'updated', message: { 'playlist_id': playlist.id }}).once

    assert_difference 'playlist.videos.count', 2 do
      playlist.import_videos
    end

    # Assigns correct values
    video = Video.find_by_api_video_id('abc123')
    assert_equal 'abc123', video.api_video_id
    assert_equal 'test video', video.api_title
    assert_equal 'http://test.com/medium.gif', video.api_thumbnail_medium_url
    assert_equal 'http://test.com/default.gif', video.api_thumbnail_default_url
    assert_equal 'http://test.com/high.gif', video.api_thumbnail_high_url
    assert_equal 'PT2M41S', video.api_duration
    assert_equal 161, video.api_duration_seconds
    assert_equal 'test channel', video.api_channel_title
    assert_equal 'testtesttest1', video.api_channel_id
    assert_equal 'https://www.youtube.com/v/abc123', video.link

    video = Video.find_by_api_video_id('abc124')
    assert_equal 'abc124', video.api_video_id
    assert_equal 'test video 2', video.api_title
    assert_equal 'http://test.com/medium2.gif', video.api_thumbnail_medium_url
    assert_equal 'http://test.com/default2.gif', video.api_thumbnail_default_url
    assert_equal 'http://test.com/high2.gif', video.api_thumbnail_high_url
    assert_equal 'PT53M32S', video.api_duration
    assert_equal 3212, video.api_duration_seconds
    assert_equal 'test channel', video.api_channel_title
    assert_equal 'testtesttest1', video.api_channel_id
    assert_equal 'https://www.youtube.com/v/abc124', video.link

    playlist.reload
    assert_equal 2, playlist.video_count
    assert !playlist.importing_videos
  end

  test 'imports new videos and cleans out old videos' do
    user = create(:user)
    playlist = create(:playlist_with_videos, api_playlist_id: 'test123', user: user, videocount: 1)
    existing_video = playlist.videos.first

    YoutubeApi.expects(:get_videos_for_playlist).with('test123', user).returns(fake_videos)
    PlaylistEventsChannel.expects(:broadcast_to).with(user, { action: 'updated', message: { 'playlist_id': playlist.id }}).once

    # Adds 2, takes away 1
    assert_difference 'playlist.videos.count', 1 do
      playlist.import_videos
    end

    assert Video.exists?(api_video_id: 'abc123')
    assert Video.exists?(api_video_id: 'abc124')
    assert !Video.exists?(existing_video.id)

    playlist.reload
    assert_equal 2, playlist.video_count
    assert !playlist.importing_videos
  end

  test 'updates existing videos' do
    user = create(:user)
    playlist = create(:playlist, api_playlist_id: 'test123', user: user)
    video1 = create(:video, parent: playlist, api_video_id: 'abc123', api_title: 'original title')
    video2 = create(:video, parent: playlist, api_video_id: 'abc124', api_title: 'original title 2')
    playlist.reload

    YoutubeApi.expects(:get_videos_for_playlist).with('test123', user).returns(fake_videos)
    PlaylistEventsChannel.expects(:broadcast_to).with(user, { action: 'updated', message: { 'playlist_id': playlist.id }}).once

    assert_no_difference 'playlist.videos.count' do
      playlist.import_videos
    end

    video = Video.find(video1.id)
    assert_equal 'abc123', video.api_video_id
    assert_equal 'test video', video.api_title
    assert_equal 'http://test.com/medium.gif', video.api_thumbnail_medium_url
    assert_equal 'http://test.com/default.gif', video.api_thumbnail_default_url
    assert_equal 'http://test.com/high.gif', video.api_thumbnail_high_url
    assert_equal 'PT2M41S', video.api_duration
    assert_equal 161, video.api_duration_seconds
    assert_equal 'test channel', video.api_channel_title
    assert_equal 'testtesttest1', video.api_channel_id
    assert_equal 'https://www.youtube.com/v/abc123', video.link

    video = Video.find(video2.id)
    assert_equal 'abc124', video.api_video_id
    assert_equal 'test video 2', video.api_title
    assert_equal 'http://test.com/medium2.gif', video.api_thumbnail_medium_url
    assert_equal 'http://test.com/default2.gif', video.api_thumbnail_default_url
    assert_equal 'http://test.com/high2.gif', video.api_thumbnail_high_url
    assert_equal 'PT53M32S', video.api_duration
    assert_equal 3212, video.api_duration_seconds
    assert_equal 'test channel', video.api_channel_title
    assert_equal 'testtesttest1', video.api_channel_id
    assert_equal 'https://www.youtube.com/v/abc124', video.link

    playlist.reload
    assert_equal 2, playlist.video_count
    assert !playlist.importing_videos
  end

  test 'does not save videos that have not changed' do
    user = create(:user)
    User.stamper = user
    playlist = create(:playlist, api_playlist_id: 'test123', user: user)

    YoutubeApi.expects(:get_videos_for_playlist).with('test123', user).returns(fake_videos).twice
    PlaylistEventsChannel.stubs(:broadcast_to).with(user, { action: 'updated', message: { 'playlist_id': playlist.id }})

    # Import them initially
    playlist.import_videos

    Video.any_instance.expects(:save!).never
    assert_no_difference 'Video.count' do
      playlist.import_videos
    end

    playlist.reload
    assert_equal 2, playlist.video_count
    assert !playlist.importing_videos
  end

  test 'imports video call still resets importing flag on exeption' do
    user = create(:user)
    playlist = create(:playlist, api_playlist_id: 'test123', user: user)

    YoutubeApi.expects(:get_videos_for_playlist).raises(Exception.new('whoops'))
    PlaylistEventsChannel.stubs(:broadcast_to).with(user, { action: 'updated', message: { 'playlist_id': playlist.id }})

    playlist.import_videos

    playlist.reload
    assert_equal 0, playlist.video_count
    assert !playlist.importing_videos
  end
end
