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
  end

  test 'imports videos' do
    skip 'TODO'
  end
end
