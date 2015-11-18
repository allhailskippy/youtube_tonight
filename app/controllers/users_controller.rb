class UsersController < ApplicationController
  def requires_auth
    @user = User.find(params[:id])
  end
end
