class UsersController < ApplicationController
  def requires_auth
    @user = User.find(params[:id])
  end

  # GET /users
  # GET /users.json
  def index
    respond_to do |format|
      format.html
      format.json do
        users = User.all

        render json: {
          data: users.as_json(User.as_json_hash)
        }
      end
    end
  end

  # GET /users/:id.json
  def show
    respond_to do |format|
      begin
        @user = User.find(params[:id])
        format.json do
          render json: {
            data: @user.as_json(User.as_json_hash)
          }
        end
      rescue ActiveRecord::RecordNotFound
        format.json do
          render json: {
            errors: 'Not Found'
          },
          status: :unprocessable_entity
        end
      rescue Exception => e
        format.json do
          render json: {
            errors: e.to_s
          },
          status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /users/:id.json
  def update
    @user = scoped.find(params[:id])
    respond_to do |format|
      begin
        @user.update_attributes!(user_params)
        format.json do
          render json: @user.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: {
            errors: @user.errors,
            full_errors: @user.errors.full_messages
          },
          status: :unprocessable_entity
        end
      rescue Exception => e
        format.json do
          render json: {
            errors: e.to_s
          },
          status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /users/:id
  def destroy
    respond_to do |format|
      begin
        @user = scoped.find(params[:id])
        @user.destroy
        format.json do
          render json: {
            :status => :ok
          }
        end
      rescue Exception => e
        format.json do
          render json: {
            :errors => [e.to_s]
          },
          status: :unprocessable_entity
        end
      end
    end
  end

private
  def scoped
    User.where(nil)
  end

  def user_params
    params.require(:user).permit(
      :id,
      :name,
      :email,
      :requires_auth,
      :role_titles => []
    )
  end
end
