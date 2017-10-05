module Permissions
  def authenticate_as_admin
    authenticate_as(users(:admin_user))
  end

  def authenticate_as_host
    authenticate_as(users(:host_user))
  end

  def authenticate_as(user)
    Authorization.current_user = user
    User.stamper = user

    sign_in(user)
    user
  end

  def current_user
    Authorization.current_user
  end

  # Logout
  def logout_user
    sign_out Authorization.current_user
  end
end
