require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def stub_google_auth
    body = %{
      {
        "access_token": "abcdefg123",
        "expires_in": 1000
      }
    }
    stub_request(:post, "https://accounts.google.com/o/oauth2/token").
                 with(body: {"client_id"=>"GOOGLE_CLIENT_ID", "client_secret"=>"GOOGLE_CLIENT_SECRET", "grant_type"=>"refresh_token", "refresh_token"=>""}).
                 to_return(status: 200, body: body, headers: { "content-type": "application/json; charset=UTF-8" })
  end

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

    assert_equal [:host], user.role_titles
    assert_equal false, user.change_roles
    assert_equal true, user.skip_playlist_import
  end

  test "relationships" do
    # has many roles
    user = create(:user, role_titles: ['whatever'])
    r1 = create(:role, user: user, title: 'admin')
    r2 = create(:role, user: user, title: 'host')
    user.reload

    assert_equal 3, user.roles.length
    assert user.roles.include?(r1)
    assert user.roles.include?(r2)
    assert user.roles.collect(&:title).include?('whatever')

    # has many playlists
    p1 = create(:playlist, user: user)
    p2 = create(:playlist, user: user)
    user.reload

    assert_equal 2, user.playlists.length
    assert user.playlists.include?(p1)
    assert user.playlists.include?(p2)

    # Has many shows through show_users
    s1 = create(:show, users: [user])
    s2 = create(:show, users: [user])
    user.reload

    assert_equal 2, user.shows.length
    assert user.shows.include?(s1)
    assert user.shows.include?(s2)

    assert_equal 2, user.show_users.length
    assert user.show_users.collect(&:show_id).include?(s1.id)
    assert user.show_users.collect(&:show_id).include?(s2.id)
  end

  test 'validation' do
    # On create
    user = User.new(requires_auth: false)
    assert !user.valid?
    assert_equal ["can't be blank"], user.errors.messages[:name]
    assert_equal ["can't be blank"], user.errors.messages[:email]
  
    # On update
    user = create(:user)
    user.role_titles = []
    user.requires_auth = false
    assert !user.valid?
    assert_equal ["must be selected"], user.errors.messages[:role_titles]
  
    user.requires_auth = true
    assert user.valid?
    assert user.errors.messages[:role_titles].blank?
  end

  test 'scopes' do
    user = create(:user, name: 'test name')
    system_admin = User.find(SYSTEM_ADMIN_ID)

    # Does find without scope
    all_users = User.all
    assert all_users.include?(user)
    assert all_users.include?(system_admin)

    # Doesn't find when using scope
    users = User.without_system_admin.all
    assert users.include?(user)
    assert !users.include?(system_admin)
  end

  test 'callbacks: deliver_registered_user_email' do
    User.any_instance.expects(:deliver_registered_user_email).once
    create(:user)
  end

  test 'callbacks: import_playlists' do
    User.any_instance.expects(:import_playlists).once
    create(:user, skip_playlist_import: false)
  end

  test 'callbacks: import_playlists - skip' do
    User.any_instance.expects(:import_playlists).never
    create(:user, skip_playlist_import: true)
  end

  test 'callbacks: update_roles' do
    User.any_instance.expects(:update_roles).once
    user = build(:user, change_roles: true)
    user.valid?
  end

  test 'callbacks: update_roles - skip' do
    User.any_instance.expects(:update_roles).never
    user = build(:user, change_roles: false)
    user.valid?
  end

  test 'callbacks: deliver_authorized_email' do
    User.any_instance.expects(:deliver_authorized_email).once
    user = create(:user, requires_auth: true)
    user.update_attribute(:requires_auth, false)
  end

  test 'callbacks: deliver_authorized_email - skip' do
    User.any_instance.expects(:deliver_authorized_email).never
    user = create(:user, requires_auth: false, name: 'test user')
    user.update_attribute(:requires_auth, true)

    user = create(:user, requires_auth: true)
    user.update_attribute(:name, 'edited user')
  end

  test 'from omniauth' do
    User.any_instance.stubs(:import_playlists)
    User.any_instance.stubs(:deliver_registered_user_email)

    auth = mock()
    auth.stubs(:provider).returns('google_oauth2')
    info = mock()
    info.stubs(:email).returns('test@test.com')
    info.stubs(:name).returns('test name')
    info.stubs(:image).returns('http://test.com/thumbnail.gif')
    auth.stubs(:info).returns(info)
    cred = mock()
    cred.stubs(:token).returns('abcd1234')
    cred.stubs(:refresh_token).returns('qwerty5678')
    cred.stubs(:expires_at).returns(987654321)
    auth.stubs(:credentials).returns(cred)

    user = User.from_omniauth(auth)

    assert_equal 'google_oauth2', user.provider
    assert_equal 'test@test.com', user.email
    assert user.requires_auth
    assert_equal 'abcd1234', user.auth_hash
    assert_equal 'qwerty5678', user.refresh_token
    assert_equal 987654321, user.expires_at
    assert_equal 'test name', user.name
    assert_equal 'http://test.com/thumbnail.gif', user.profile_image
  end

  test 'role_symbols' do
    user = User.new
    assert_equal [], user.role_symbols

    user = create(:user, role_titles: ['admin', 'host'])
    assert_equal 2, user.role_symbols.length
    assert user.role_symbols.include?(:admin)
    assert user.role_symbols.include?(:host)
  end

  test 'role_titles' do
    user = User.new
    assert_equal [], user.role_titles

    user = create(:user, role_titles: ['admin', 'host'])
    assert_equal 2, user.role_titles.length
    assert user.role_titles.include?(:admin)
    assert user.role_titles.include?(:host)

    # Reload so role_titles isn't set already
    user = User.find(user.id)

    assert_equal 2, user.role_titles.length
    assert user.role_titles.include?(:admin)
    assert user.role_titles.include?(:host)
  end

  test 'has_role(s)' do
    user = create(:user, role_titles: ['role1', 'role2'])
    assert user.has_role(:role1)
    assert user.has_role(:role2)
    assert !user.has_role(:not_found)

    user = User.find(user.id)
    assert user.has_role(:role1)
    assert user.has_role(:role2)
    assert !user.has_role(:not_found)

    user = create(:user, role_titles: ['role1', 'role2'])
    assert user.has_roles(:role1)
    assert user.has_roles(:role2)
    assert !user.has_roles(:not_found)
    assert user.has_roles(:role1, :role2, :not_found)
    assert !user.has_roles(:not_found, :not_found_either)
  end

  test 'has custom json attributes' do
    user = create(:user)

    juser = JSON.parse(user.to_json)
    keys = [
      "id", "provider", "uid", "name", "email", "profile_image", "auth_hash",
      "expires_at", "creator_id", "updater_id", "created_at", "updated_at",
      "deleted_at", "version", "requires_auth", "importing_playlists",
      "refresh_token", "role_titles", "is_admin", "roles"
    ]
    keys.each do |key|
      assert juser.keys.include?(key)
    end
  end

  test 'is_admin' do
    user = create(:user, role_titles: ['admin'])
    assert user.is_admin

    user = create(:user, role_titles: ['not_admin'])
    assert !user.is_admin

    user = create(:user, role_titles: ['admin', 'host'])
    assert user.is_admin
  end

  test 'gets token' do
    # Not expired
    user = create(:user, expires_at: Time.now + 1.day, auth_hash: 'abcd1234abcd')
    assert 'abcd1234abcd', user.get_token

    # Expired
    user = create(:user, expires_at: Time.now - 1.day)
    user.stubs(:get_refresh_token).returns('qwerty4321qwerty')

    assert 'qwerty4321qwerty', user.get_token
  end

  test 'checks to see if token is expired' do
    stub_google_auth

    # Not expired
    user = create(:user, expires_at: Time.now + 1.day)
    assert !user.token_expired?

    # Expired but refreshes token
    user = create(:user, expires_at: Time.now - 1.day)
    assert !user.token_expired?

    # Expired and token can't be refreshed
    user = create(:user, expires_at: Time.now - 1.day)
    user.stubs(:get_refresh_token).raises(Exception.new("error"))
    assert user.token_expired?
  end

  test 'get the refresh token' do
    expected_time = Time.now + 1000.seconds
    stub_google_auth

    user = create(:user)
    auth_hash = user.get_refresh_token

    assert_equal "abcdefg123", auth_hash
    assert_equal "abcdefg123", user.auth_hash
    assert_equal expected_time.to_i, user.expires_at
  end

  test 'imports playlists' do
    skip 'TODO'
  end

  #############################################################################
  # Protected methods
  #############################################################################
  test 'updates roles - current_user is admin' do
    user = create(:user, role_titles: ['role1', 'role2'], requires_auth: false)
    user.role_titles = ['role3', 'admin']
    user.send(:update_roles)

    assert_equal 2, user.roles.length
    assert user.roles.collect(&:title).include?('role3')
    assert user.roles.collect(&:title).include?('admin')

    # Requires auth is on, will clear roles
    user = create(:user, role_titles: ['role1', 'role2'], requires_auth: true)
    user.role_titles = ['role3', 'admin']
    user.send(:update_roles)

    assert_equal 0, user.roles.length
  end

  test 'updates roles - current_user is not admin' do
    user = create(:user, role_titles: ['host'])
    Authorization.current_user = user

    user = create(:user, role_titles: ['role1', 'role2'], requires_auth: false)
    user.role_titles = ['role3', 'admin']
    user.send(:update_roles)

    assert_equal 1, user.roles.length
    assert user.roles.collect(&:title).include?('role3')

    # Requires auth is on, will clear roles
    user = create(:user, role_titles: ['role1', 'role2'], requires_auth: true)
    user.role_titles = ['role3', 'admin']
    user.send(:update_roles)

    assert_equal 0, user.roles.length
  end
end
