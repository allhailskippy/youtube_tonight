class CurrentUserController < ApplicationController
  # GET /current_user.json
  def index
    authorize :current_user, :index?
    if current_user
      user_info = UserInfo.new(current_user).user_info
      user_info.merge!(xCSRFToken: form_authenticity_token)
    else
      user_info = {}
    end
    respond_to do |format|
      format.json do
        render json: { data: user_info }
      end
    end
  end
end
