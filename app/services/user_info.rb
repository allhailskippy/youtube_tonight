class UserInfo
  @current_user = nil;

  def initialize(user = nil)
    @current_user = user
  end

  def user_info
    {
      id: @current_user.id,
      name: @current_user.name,
      email: @current_user.email,
      profile_image: @current_user.profile_image,
      role_titles: @current_user.role_symbols,
      is_admin: @current_user.is_admin,
      requires_auth: @current_user.requires_auth,
      authRules: auth_rules
    }
  end

private

  def auth_rules
    privileges = [
      :callback,
      :current_user,
      :user,
      :devise_session,
      :app,
      :youtube_parser,
      :broadcast,
      :show,
      :playlist,
      :video
    ]
    privileges.inject({}) do |acc, priv|
      policy = Pundit.policy(@current_user, priv)
      acc[priv] = policy.attrs.map do |attr|
        allowed = policy.public_send(attr) rescue false
        allowed ? attr : nil
      end.compact.map{|a| a.to_s.gsub(/\?$/,'') }
      acc
    end
  end
end
