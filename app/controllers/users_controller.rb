class UsersController < ApplicationController
  # GET /users/:id/requires_auth
  def requires_auth
    @user = User.find(params[:id])
    authorize(@user, :requires_auth?)

    redirect_to root_path unless @user.requires_auth
  end

  # GET /users.json
  def index
    respond_to do |format|
      format.json do
        begin
          params[:q] ||= {}
          params[:q][:s] ||= 'id desc'
          params[:per_page] ||= 100000
          params[:page] ||= 1

          # Prevent pagination from being 0 or lower
          params[:page] = params[:page].to_i < 1 ? '1' : params[:page]
          params[:per_page] = params[:per_page].to_i < 1 ? '1' : params[:per_page]

          authorize(:user, :index?)

          search = policy_scope(User).search(params[:q])
          users = search.result.paginate(:page => params[:page], :per_page => params[:per_page])

          render json: {
            page: params[:page],
            per_page: params[:per_page],
            total: users.total_entries,
            total_pages: users.total_pages,
            offset: users.offset,
            data: users
          }
        rescue Pundit::NotAuthorizedError
          render json: { errors: ['Unauthorized'] },
                 status: :unauthorized
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # GET /users/:id.json
  def show
    respond_to do |format|
      format.json do
        begin
          user = User.find(params[:id])
          authorize(user, :show?)

          render json: { data: user }
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue Pundit::NotAuthorizedError
          render json: { errors: ['Unauthorized'] },
                 status: :unauthorized
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /users/:id.json
  def update
    respond_to do |format|
      format.json do
        begin
          user = User.find(params[:id])
          authorize(user, :update?)
          user.update_attributes!(user_params)

          # Gets rid of user/hosts cache values
          user = User.find(user.id)

          render json: { data: user }
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue ActiveRecord::RecordInvalid
          render json: { errors: user.errors, full_errors: user.errors.full_messages },
                 status: :unprocessable_entity
        rescue Pundit::NotAuthorizedError
          render json: { errors: ['Unauthorized'] },
                 status: :unauthorized
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s.titleize] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /users/:id
  def destroy
    respond_to do |format|
      format.json do
        begin
          user = User.find(params[:id])
          authorize(user, :destroy?)
          user.destroy

          render json: { data: {} }
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue Pundit::NotAuthorizedError
          render json: { errors: ['Unauthorized'] },
                 status: :unauthorized
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { :errors => [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

private
  def user_params
    params.fetch(:user, {}).permit(
      :id,
      :name,
      :email,
      :requires_auth,
      :change_roles,
      :role_titles => []
    )
  end
end
