require 'test_helper'
 
class UserTest < ActiveSupport::TestCase
  test 'model stamper' do
    stamp = create(:user)
    User.stamper = stamp
    user = create(:user)

    assert_equal stamp, user.creator 
    assert_equal stamp, user.updater
  end

  test 'attr_accessors' do
    user = create(:user)
    user.role_titles = ['host']
    user.change_roles = false
    user.skip_playlist_import = true

    assert_equal ['host'], user.role_titles
    assert_equal false, user.change_roles
    assert_equal true, user.skip_playlist_import
  end
#
#  test "relationships" do
#    # has many vidoes
#    show = create(:show)
#    v1 = create(:video, parent: show)
#    v2 = create(:video, parent: show)
#    show.reload
#
#    assert_equal 2, show.videos.length
#    assert show.videos.include?(v1)
#    assert show.videos.include?(v2)
#
#    # Has many users through show_users
#    u1 = create(:user)
#    u2 = create(:user)
#    show = create(:show, users: [u1, u2])
#    
#    assert_equal 2, show.users.length
#    assert show.users.include?(u1)
#    assert show.users.include?(u2)
#
#    assert_equal 2, show.show_users.length
#    assert show.show_users.collect(&:user_id).include?(u1.id)
#    assert show.show_users.collect(&:user_id).include?(u2.id)
#  end
#
#  test 'validation' do
#    show = Show.new
#    assert !show.valid?
#    assert_equal ["can't be blank"], show.errors.messages[:title]
#    assert_equal ["must be selected"], show.errors.messages[:hosts]
#    assert_equal ["is not a date"], show.errors.messages[:air_date]
#
#    # Air date must be in the future
#    show.air_date = Date.yesterday.to_s(:db)
#    assert !show.valid?
#    expected = ["must be after or equal to #{Date.today.to_s(:db)}"]
#    assert_equal expected, show.errors.messages[:air_date]
#
#    # Air date can be in the past on update
#    show = create(:show)
#    show.air_date = Date.yesterday.to_s(:db)
#    assert show.valid?
#    assert show.save
#
#    # But must still be a date
#    show.air_date = "asdf"
#    assert !show.valid?
#    expected = ["is not a date"]
#    assert_equal expected, show.errors.messages[:air_date]
#  end
#
#  test 'has hosts reader' do
#    # From user relation
#    u1 = create(:user)
#    u2 = create(:user)
#    show = create(:show, users: [u1, u2])
#    expected = "#{u1.id},#{u2.id}"
#    assert_equal expected, show.hosts
#
#    # From @hosts
#    u3 = create(:user)
#    u4 = create(:user)
#    show = create(:show, users: [u1])
#    show.hosts = "#{u4.id},#{u3.id}"
#    expected = "#{u4.id},#{u3.id}"
#    assert_equal expected, show.hosts
#  end
#
#  test 'has hosts writer' do
#    u1 = create(:user)
#    u2 = create(:user)
#    u3 = create(:user)
#
#    show = create(:show, users: [u1, u2])
#    show.hosts = "#{u3.id},#{u2.id}"
#
#    assert show.save
#    show.reload
#
#    assert_equal 2, show.users.length
#    assert show.users.include?(u2)
#    assert show.users.include?(u3)
#  end
#
#  test 'has video_count reader' do
#    show = create(:show_with_videos, video_count: 10)
#    assert_equal 10, show.video_count
#
#    show.videos << build(:video)
#    assert_equal 11, show.video_count
#  end
#
#  test 'has custom json attributes' do
#    show = create(:show)
#    
#    jshow = JSON.parse(show.to_json)
#    assert jshow.keys.include?("users")
#    assert jshow.keys.include?("video_count")
#    assert jshow.keys.include?("hosts")
#  end
end
