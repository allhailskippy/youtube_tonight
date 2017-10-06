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

    auth = stub(
      provider: 'google_oauth2',
      info: stub(
        email: 'test@test.com',
        name: 'test name',
        image: 'http://test.com/thumbnail.gif'
      ),
      credentials: stub(
        token: 'abcd1234',
        refresh_token: 'qwerty5678',
        expires_at: 987654321
      )
    )
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

  def fake_playlists
    {
      playlist1: {
        playlist_id: 'abcd1234',
        title: 'test title',
        description: 'this is a description for a playlist',
        thumbnails: stub(
          default: stub(url: 'http://test.com/default.gif', width: 120, height: 90),
          medium: stub(url: 'http://test.com/medium.gif', width: 320, height: 180),
          high: stub(url: 'http://test.com/high.gif', width: 480, height: 360),
          standard: stub(url: 'http://test.com/standard.gif', width: 640, height: 480),
          maxres: stub(url: 'http://test.com/maxres.gif', width: 1280, height: 720)
        )
      }, playlist2: {
        playlist_id: 'qwerty12345',
        title: 'test title 2',
        description: 'this is another description for a playlist',
        thumbnails: stub(
          default: stub(url: 'http://test.com/default2.gif', width: 120, height: 90),
          medium: stub(url: 'http://test.com/medium2.gif', width: 320, height: 180),
          high: stub(url: 'http://test.com/high2.gif', width: 480, height: 360),
          standard: stub(url: 'http://test.com/standard2.gif', width: 640, height: 480),
          maxres: stub(url: 'http://test.com/maxres2.gif', width: 1280, height: 720)
        )
      }
    }
  end

  test 'imports playlists' do
    user = create(:user)
    User.stamper = user

    YoutubeApi.expects(:get_playlists).with(user).returns(fake_playlists)
    VideoImportWorker.expects(:perform_async).twice

    assert_difference 'user.playlists.count', 2 do
      user.import_playlists
    end

    # Assigns correct values
    playlist = Playlist.find_by_api_playlist_id('abcd1234')
    assert_equal user.id, playlist.user_id
    assert_equal 'abcd1234', playlist.api_playlist_id
    assert_equal 'test title', playlist.api_title
    assert_equal 'http://test.com/default.gif', playlist.api_thumbnail_default_url
    assert_equal 120, playlist.api_thumbnail_default_width
    assert_equal 90, playlist.api_thumbnail_default_height
    assert_equal 'http://test.com/medium.gif', playlist.api_thumbnail_medium_url
    assert_equal 320, playlist.api_thumbnail_medium_width
    assert_equal 180, playlist.api_thumbnail_medium_height
    assert_equal 'http://test.com/high.gif', playlist.api_thumbnail_high_url
    assert_equal 480, playlist.api_thumbnail_high_width
    assert_equal 360, playlist.api_thumbnail_high_height
    assert_equal 'http://test.com/standard.gif', playlist.api_thumbnail_standard_url
    assert_equal 640, playlist.api_thumbnail_standard_width
    assert_equal 480, playlist.api_thumbnail_standard_height
    assert_equal 'http://test.com/maxres.gif', playlist.api_thumbnail_maxres_url
    assert_equal 1280, playlist.api_thumbnail_maxres_width
    assert_equal 720, playlist.api_thumbnail_maxres_height
    assert_equal user.id, playlist.creator_id
    assert_equal user.id, playlist.updater_id

    playlist = Playlist.find_by_api_playlist_id('qwerty12345')
    assert_equal user.id, playlist.user_id
    assert_equal 'qwerty12345', playlist.api_playlist_id
    assert_equal 'test title 2', playlist.api_title
    assert_equal 'http://test.com/default2.gif', playlist.api_thumbnail_default_url
    assert_equal 120, playlist.api_thumbnail_default_width
    assert_equal 90, playlist.api_thumbnail_default_height
    assert_equal 'http://test.com/medium2.gif', playlist.api_thumbnail_medium_url
    assert_equal 320, playlist.api_thumbnail_medium_width
    assert_equal 180, playlist.api_thumbnail_medium_height
    assert_equal 'http://test.com/high2.gif', playlist.api_thumbnail_high_url
    assert_equal 480, playlist.api_thumbnail_high_width
    assert_equal 360, playlist.api_thumbnail_high_height
    assert_equal 'http://test.com/standard2.gif', playlist.api_thumbnail_standard_url
    assert_equal 640, playlist.api_thumbnail_standard_width
    assert_equal 480, playlist.api_thumbnail_standard_height
    assert_equal 'http://test.com/maxres2.gif', playlist.api_thumbnail_maxres_url
    assert_equal 1280, playlist.api_thumbnail_maxres_width
    assert_equal 720, playlist.api_thumbnail_maxres_height
    assert_equal user.id, playlist.creator_id
    assert_equal user.id, playlist.updater_id

    user.reload
    assert !user.importing_playlists
  end

  test 'imports new videos and cleans out old playlists' do
    user = create(:user)
    playlist = create(:playlist, user: user)

    YoutubeApi.expects(:get_playlists).with(user).returns(fake_playlists)
    VideoImportWorker.expects(:perform_async).twice

    # Adds 2, takes away 1
    assert_difference 'user.playlists.count', 1 do
      user.import_playlists
    end

    assert Playlist.exists?(api_playlist_id: 'abcd1234')
    assert Playlist.exists?(api_playlist_id: 'qwerty12345')
    assert !Playlist.exists?(playlist.id)

    user.reload
    assert !user.importing_playlists
  end

  test 'updates existing playlists' do
    user = create(:user)
    User.stamper = user

    playlist1 = create(:playlist, user: user, api_playlist_id: 'abcd1234', api_title: 'original title')
    playlist2 = create(:playlist, user: user, api_playlist_id: 'qwerty12345', api_title: 'original title 2')

    YoutubeApi.expects(:get_playlists).with(user).returns(fake_playlists)
    VideoImportWorker.expects(:perform_async).twice

    assert_no_difference 'user.playlists.count' do
      user.import_playlists
    end

    playlist = Playlist.find(playlist1.id)
    assert_equal user.id, playlist.user_id
    assert_equal 'abcd1234', playlist.api_playlist_id
    assert_equal 'test title', playlist.api_title
    assert_equal 'http://test.com/default.gif', playlist.api_thumbnail_default_url
    assert_equal 120, playlist.api_thumbnail_default_width
    assert_equal 90, playlist.api_thumbnail_default_height
    assert_equal 'http://test.com/medium.gif', playlist.api_thumbnail_medium_url
    assert_equal 320, playlist.api_thumbnail_medium_width
    assert_equal 180, playlist.api_thumbnail_medium_height
    assert_equal 'http://test.com/high.gif', playlist.api_thumbnail_high_url
    assert_equal 480, playlist.api_thumbnail_high_width
    assert_equal 360, playlist.api_thumbnail_high_height
    assert_equal 'http://test.com/standard.gif', playlist.api_thumbnail_standard_url
    assert_equal 640, playlist.api_thumbnail_standard_width
    assert_equal 480, playlist.api_thumbnail_standard_height
    assert_equal 'http://test.com/maxres.gif', playlist.api_thumbnail_maxres_url
    assert_equal 1280, playlist.api_thumbnail_maxres_width
    assert_equal 720, playlist.api_thumbnail_maxres_height
    assert_equal user.id, playlist.creator_id
    assert_equal user.id, playlist.updater_id

    playlist = Playlist.find(playlist2.id)
    assert_equal user.id, playlist.user_id
    assert_equal 'qwerty12345', playlist.api_playlist_id
    assert_equal 'test title 2', playlist.api_title
    assert_equal 'http://test.com/default2.gif', playlist.api_thumbnail_default_url
    assert_equal 120, playlist.api_thumbnail_default_width
    assert_equal 90, playlist.api_thumbnail_default_height
    assert_equal 'http://test.com/medium2.gif', playlist.api_thumbnail_medium_url
    assert_equal 320, playlist.api_thumbnail_medium_width
    assert_equal 180, playlist.api_thumbnail_medium_height
    assert_equal 'http://test.com/high2.gif', playlist.api_thumbnail_high_url
    assert_equal 480, playlist.api_thumbnail_high_width
    assert_equal 360, playlist.api_thumbnail_high_height
    assert_equal 'http://test.com/standard2.gif', playlist.api_thumbnail_standard_url
    assert_equal 640, playlist.api_thumbnail_standard_width
    assert_equal 480, playlist.api_thumbnail_standard_height
    assert_equal 'http://test.com/maxres2.gif', playlist.api_thumbnail_maxres_url
    assert_equal 1280, playlist.api_thumbnail_maxres_width
    assert_equal 720, playlist.api_thumbnail_maxres_height
    assert_equal user.id, playlist.creator_id
    assert_equal user.id, playlist.updater_id

    user.reload
    assert !user.importing_playlists
  end

  test 'does not save playlists that have not changed' do
    user = create(:user)
    User.stamper = user

    YoutubeApi.expects(:get_playlists).with(user).returns(fake_playlists).twice
    VideoImportWorker.expects(:perform_async).times(4)

    # Import them initially
    user.import_playlists

    Playlist.any_instance.expects(:save!).never
    assert_no_difference 'user.playlists.count' do
      user.import_playlists
    end

    user.reload
    assert !user.importing_playlists
  end

  test 'imports playlist call still resets importing flag on exeption' do
    user = create(:user)

    YoutubeApi.expects(:get_playlists).raises(Exception.new('whoops'))
    VideoImportWorker.expects(:perform_async).never

    assert_no_difference('user.playlists.count') do
      user.import_playlists
    end

    user.reload
    assert !user.importing_playlists
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
