require 'test_helper'

class CurrentUserControllerTest < ActionDispatch::IntegrationTest
  ##
  # Routes
  ##
  test 'should check routes' do
    assert_routing '/current_user.json', controller: 'current_user', action: 'index', format: 'json'
  end

  ##
  # Index
  ##
  test 'Admin: should get index as json' do
    user = authenticate_as_admin

    get current_user_url(format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    data = results["data"]
    assert_equal data["id"], 1
    assert_equal data["name"], "Admin User"
    assert_equal data["email"], "admin@example.com"
    assert_equal data["profile_image"], "http://localhost/admin.gif"
    assert_equal data["role_titles"], ["admin"]
    assert_equal data["is_admin"], true
    assert_equal data["requires_auth"], false
    expected = {
      "callback": ["google_oauth2", "failure"],
      "current_user": ["index"],
      "user": ["index", "show", "create", "update", "destroy", "read", "manage", "requires_auth", "import_playlists"],
      "devise_session": ["index", "show", "create", "update", "destroy", "read", "manage"],
      "app": ["index"],
      "youtube_parser": ["index"],
      "broadcast": ["index"],
      "show": ["index", "show", "create", "update", "destroy", "read", "manage"],
      "playlist": ["index", "show", "create", "update", "destroy", "read", "manage"],
      "video": ["index", "show", "create", "update", "destroy", "read", "manage"]
    }
    assert_equal expected.with_indifferent_access, data["authRules"]
  end

  test 'Host: should get index as json' do
    authenticate_as_host

    get current_user_url(format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_not_empty results

    data = results["data"]
    assert_equal data["id"], 2
    assert_equal data["name"], "Host User"
    assert_equal data["email"], "host@example.com"
    assert_equal data["profile_image"], "http://localhost/host.gif"
    assert_equal data["role_titles"], ["host"]
    assert_equal data["is_admin"], false
    assert_equal data["requires_auth"], false
    expected = {
      "callback": ["google_oauth2", "failure"],
      "current_user": ["index"],
      "user": ["show", "requires_auth"],
      "devise_session": ["index", "show", "create", "update", "destroy", "read", "manage"],
      "app": ["index"],
      "youtube_parser": ["index"],
      "broadcast": ["index"],
      "show": ["index"],
      "playlist": ["index"],
      "video": ["index","create"]
    }
    assert_equal expected.with_indifferent_access, data["authRules"]
  end

  test 'Guest: should get index as json' do
    get current_user_url(format: :json)
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal results, { "data" => {}}
  end
end
