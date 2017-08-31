class CurrentUserController < ApplicationController
  # GET /current_user.json
  def index
    respond_to do |format|
      format.json {
        render json: { data: Authorization.current_user.as_json(User.as_json_hash) }
      }
    end
  end
end
