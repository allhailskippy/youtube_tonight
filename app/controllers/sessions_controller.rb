class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    auth_hash = {
      auth_hash: auth.credentials.token,
      email: auth.info.email,
      expires_at: auth.credentials.expires_at,
      facebook_id: auth.uid,
      name: auth.info.name,
      profile_image: auth.info.image
    }
    @user = User.find_or_create_by_facebook_id(auth_hash)
    @user.update_attributes(auth_hash)
#    Self.current_user = @user
    redirect_to shows_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
