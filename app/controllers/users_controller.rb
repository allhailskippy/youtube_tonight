class UsersController < ApplicationController
  def requires_auth
    @user = User.find(params[:id])
    redirect_to root_path unless @user.requires_auth
  end

  # GET /users
  # GET /users.json
  def index
    respond_to do |format|
      format.html
      format.json do
        params[:q] ||= {}
        params[:q][:s] ||= 'id desc'
        params[:per_page] ||= 100000
        params[:page] ||= 1

        search = User.without_system_admin.with_permissions_to(:read).search(params[:q])
        users = search.result.paginate(:page => params[:page], :per_page => params[:per_page])

        render json: { data: users.as_json(User.as_json_hash) }
      end
    end
  end

  # GET /users/:id.json
  def show
    respond_to do |format|
      begin
        user = User.with_permissions_to(:read).find(params[:id])
        format.json do
          render json: { data: user.as_json(User.as_json_hash) }
        end
      rescue ActiveRecord::RecordNotFound
        format.json do
          render json: { errors: 'Not Found' },
                 status: :unprocessable_entity
        end
      rescue Exception => e
        NewRelic::Agent.notice_error(e)
        format.json do
          render json: { errors: e.to_s },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /users/:id.json
  def update
    user = scoped.find(params[:id])
    respond_to do |format|
      begin
        permitted_to!(:update, user)
        user.update_attributes!(user_params)
        format.json do
          render json: user.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: { errors: user.errors, full_errors: user.errors.full_messages },
                 status: :unprocessable_entity
        end
      rescue Exception => e
        NewRelic::Agent.notice_error(e)
        format.json do
          render json: { errors: e.to_s },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /users/:id
  def destroy
    respond_to do |format|
      begin
        user = scoped.find(params[:id])
        permitted_to!(:delete, user)
        user.destroy

        format.json do
          render json: { :status => :ok }
        end
      rescue Exception => e
        NewRelic::Agent.notice_error(e)
        format.json do
          render json: { :errors => [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

private
  def scoped
    User.with_permission_to(:read).all
  end

  def user_params
    params.require(:user).permit(
      :id,
      :name,
      :email,
      :requires_auth,
      :change_roles,
      :role_titles => []
    )
  end
end
