class CurrentUserControllerTest < ActionController::TestCase
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
    user = login_as_admin

    get :index, format: :json
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
      "authorizationRules": ["index", "show"], 
      "callbacks": ["google_oauth2", "failure"], 
      "currentUser": ["index"], 
      "users": ["edit", "requires_auth", "import_playlists", "create", "read", "update", "delete", "index", "show"], 
      "deviseSessions": ["create", "read", "update", "delete", "index", "show"],
      "app": ["index"], 
      "youtubeParser": ["index", "show"], 
      "broadcasts": ["index", "show"], 
      "shows": ["create", "read", "update", "delete", "index", "show"], 
      "playlists": ["create", "read", "update", "delete", "index", "show"], 
      "videos": ["create", "read", "update", "delete", "index", "show"]
    } 
    assert_equal data["authRules"], expected.with_indifferent_access
  end

  test 'Host: should get index as json' do
    login_as_host

    get :index, format: :json
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
      "authorizationRules": ["index", "show"], 
      "callbacks": ["google_oauth2", "failure"], 
      "currentUser": ["index"], 
      "users": ["edit", "requires_auth", "show", "import_playlists"], 
      "deviseSessions": ["create", "read", "update", "delete", "index", "show"],
      "app": ["index"], 
      "shows": ["index", "show"], 
      "youtubeParser": ["index", "show"], 
      "broadcasts": ["index", "show"], 
      "playlists": ["create", "read", "update", "delete", "index", "show"], 
      "videos": ["index", "show", "create", "read", "update", "delete"]
    } 
    assert_equal data["authRules"], expected.with_indifferent_access
  end

  test 'Guest: should get index as json' do
    get :index, format: :json
    assert_response :success

    results = JSON.parse(response.body)
    assert_equal results, { "data" => {}}
  end
end
