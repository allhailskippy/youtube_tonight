class ShowsController < ApplicationController
  # GET /shows.json
  def index
    respond_to do |format|
      format.json do
        begin
          shows = Show.includes(:videos).with_permissions_to(:index).all
          render json: { data: shows }
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # GET /shows/:id.json
  def show
    respond_to do |format|
      format.json do
        begin
          show = Show.find(params[:id])

          # Used to differentiate between not found and not authorized
          permitted_to!(:show, show)

          render json: { data: show }
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue Authorization::NotAuthorized, Authorization::AttributeAuthorizationError
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

  # POST /shows.json
  def create
    respond_to do |format|
      format.json do
        begin
          show = Show.all.build(show_params)

          permitted_to!(:create, show)
          show.save!

          render json: { data: show }
        rescue ActiveRecord::RecordInvalid
          render json: { errors: show.errors, full_errors: show.errors.full_messages },
                 status: :unprocessable_entity
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /shows/:id.json
  def update
    respond_to do |format|
      format.json do
        begin
          show = Show.find(params[:id])

          permitted_to!(:update, show)
          show.update_attributes!(show_params)

          # Gets rid of user/hosts cache values
          show = Show.find(show.id)

          render json: { data: show }
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue ActiveRecord::RecordInvalid
          render json: { errors: show.errors, full_errors: show.errors.full_messages },
                 status: :unprocessable_entity
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s.titleize] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /shows/:id
  def destroy
    respond_to do |format|
      format.json do
        begin
          show = Show.find(params[:id])
          permitted_to!(:delete, show)
          show.destroy

          render json: { data: {} }
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { :errors => [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

private
  def show_params
    params.fetch(:show, {}).permit(:title, :air_date, :hosts)
  end
end
