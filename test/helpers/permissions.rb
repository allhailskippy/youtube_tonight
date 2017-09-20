module Permissions
  def login_as_admin
    login_as(users(:admin_user))
  end

  def login_as_host
    login_as(users(:host_user))
  end

  def login_as(user)
    without_access_control do
      Authorization.current_user = user
      User.stamper = user

      sign_in(user)
      user
    end
  end

  def current_user
    Authorization.current_user
  end

  # Logout
  def logout_user
    without_access_control do
      sign_out Authorization.current_user
    end
  end
end
