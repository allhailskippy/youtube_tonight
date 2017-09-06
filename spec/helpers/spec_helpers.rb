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

  def set_omniauth(user)
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
      provider: "google",
      uid: "12345678910",
      info: {
        email: user.email,
        name: user.name,
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
    res = page.evaluate_script(injector_script)
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
end
