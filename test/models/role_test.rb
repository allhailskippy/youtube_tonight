require 'test_helper'
 
class RoleTest < ActiveSupport::TestCase
  test 'model stamper' do
    stamp = create(:user)
    User.stamper = stamp

    u = create(:user, role_titles: [], requires_auth: false)
    role = create(:role, user: u)

    assert_equal stamp, role.creator 
    assert_equal stamp, role.updater
  end

  test "relationships" do
    # belongs to user
    user = create(:user)  
    playlist = create(:playlist, user: user)
    assert_equal user, playlist.user
  end

  test 'validation' do
    # Title presence
    role = Role.new
    assert !role.valid?
    assert_equal ["can't be blank"], role.errors.messages[:title]
    
    # Title uniqueness
    user = create(:user, role_titles: [], requires_auth: true)
    create(:role, user: user, title: 'test')

    role = build(:role, user: user, title: 'test')
    assert !role.valid?
    assert_equal ["has already been taken"], role.errors.messages[:title]

    # can create for another user
    role = build(:role, title: 'test')
    assert role.valid?
  end
end
