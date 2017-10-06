require 'test_helper'

class UserInfoServiceTest < ActiveSupport::TestCase
  test 'gets user_info - host' do
    user = create(:user, name: 'Test Name', email: 'test@email.com', profile_image: 'http://example.com/thumbnail.gif', role_titles: ['host'], requires_auth: false)

    user_info = UserInfo.new(user).user_info
    assert_equal user.id, user_info[:id]
    assert_equal 'Test Name', user_info[:name]
    assert_equal 'test@email.com', user_info[:email]
    assert_equal 'http://example.com/thumbnail.gif', user_info[:profile_image]
    assert_equal [:host], user_info[:role_titles]
    assert !user_info[:is_admin]
    assert !user_info[:requires_auth]
    expected = {
      callback: ["google_oauth2", "failure"],
      current_user: ["index"],
      user: ["show", "requires_auth"],
      devise_session: ["index", "show", "create", "update", "destroy", "read", "manage"],
      app: ["index"],
      youtube_parser: ["index"],
      broadcast: ["index"],
      show: ["index"],
      playlist: ["index"],
      video: ["index", "create"]
    }
    assert_equal expected, user_info[:authRules]
  end

  test 'gets user_info - admin' do
    user = create(:user, name: 'Sir Admin', email: 'admin@email.com', profile_image: 'http://example.com/admin.gif', role_titles: ['admin'], requires_auth: false)

    user_info = UserInfo.new(user).user_info
    assert_equal user.id, user_info[:id]
    assert_equal 'Sir Admin', user_info[:name]
    assert_equal 'admin@email.com', user_info[:email]
    assert_equal 'http://example.com/admin.gif', user_info[:profile_image]
    assert_equal [:admin], user_info[:role_titles]
    assert user_info[:is_admin]
    assert !user_info[:requires_auth]
    expected = {
      callback: ["google_oauth2", "failure"],
      current_user: ["index"],
      user: ["index", "show", "create", "update", "destroy", "read", "manage", "requires_auth", "import_playlists"],
      devise_session: ["index", "show", "create", "update", "destroy", "read", "manage"],
      app: ["index"],
      youtube_parser: ["index"],
      broadcast: ["index"],
      show: ["index", "show", "create", "update", "destroy", "read", "manage"],
      playlist: ["index", "show", "create", "update", "destroy", "read", "manage"],
      video: ["index", "show", "create", "update", "destroy", "read", "manage"]
    }
    assert_equal expected, user_info[:authRules]
  end

  test 'gets user_info - requires auth' do
    user = create(:user, name: 'Test Name', email: 'test@email.com', profile_image: 'http://example.com/thumbnail.gif', role_titles: [], requires_auth: true)

    user_info = UserInfo.new(user).user_info
    assert_equal user.id, user_info[:id]
    assert_equal 'Test Name', user_info[:name]
    assert_equal 'test@email.com', user_info[:email]
    assert_equal 'http://example.com/thumbnail.gif', user_info[:profile_image]
    assert_equal [], user_info[:role_titles]
    assert !user_info[:is_admin]
    assert user_info[:requires_auth]
    expected = {
      callback: ["google_oauth2", "failure"],
      current_user: ["index"],
      user: ["requires_auth"],
      devise_session: ["index", "show", "create", "update", "destroy", "read", "manage"],
      app: ["index"],
      youtube_parser: [],
      broadcast: [],
      show: [],
      playlist: [],
      video: ["index"]
    }
    assert_equal expected, user_info[:authRules]
  end
end
