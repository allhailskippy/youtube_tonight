require 'timeout'

module SpecHelpers
  def screenshot(opts={})
    filename = "/tmp/capybara-#{Time.now.to_f}.png"
    save_screenshot filename, { full: true }.merge(opts)
    system("open '#{filename}'")
  end

  def blur
    find('body').click
  end

  def stub_confirm(result)
    page.execute_script("window.confirm = function() { return #{result.to_s}; };")
  end

  def set_authorization(user)
    Authorization.current_user = user
    User.stamper = user
  end

  def set_omniauth(user = nil)
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "12345678910",
      info: {
        email: user.try(:email) || 'fake@email.com',
        name: user.try(:name) || "Fake User"
      }, 
      credentials: {
        token: "abcdefg12345",
        refresh_token: "12345abcdefg",
        expires_at: DateTime.now.to_i + 1000
      }
    })
  end

  def sign_in(user)
    login_as(user, :scope => :user)
    set_authorization(user)
  end

  def sign_in_admin()
    admin = create_user(role_titles: [:admin])
    sign_in(admin)
  end

  def sign_in_host()
    host = create_user(role_titles: [:host])
    sign_in(host)
  end

  def wait_until
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        break if yield
      end
    end
  end

  def ng_app
    ng_app = "(document.querySelectorAll('[ng-app]').length ? document.querySelectorAll('[ng-app]')[0] : document)"
  end

  def angular_is_available?
    is_angular = page.evaluate_script("typeof(angular) != 'undefined';")

    return false unless is_angular

    injector_script = <<-JS
      angular.element(#{ng_app}).injector()
    JS
    res = nil
    wait_until do
      res = page.evaluate_script(injector_script)
      res != nil
    end

    return false unless res

    true
  end

  def wait_for_angular_requests_to_finish
    return unless angular_is_available?

    script = <<-JS
      angular.element(#{ng_app}).injector().invoke(function($http) { return $http.pendingRequests; }).length
    JS

    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        pending_requests = page.evaluate_script(script)
        break if pending_requests == 0
        sleep 0.25
      end
    end
  end

  def scroll_by(y)
    page.execute_script "window.scrollBy(0,#{y});"
  end

  def scroll_to(y)
    page.execute_script "window.scrollTo(0,#{y});"
  end

  def create_user(options = {})
    u = without_access_control do
      create(:user, options)
    end
    User.find(u.id)
  end
end
