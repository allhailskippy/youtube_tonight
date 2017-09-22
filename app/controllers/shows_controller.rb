class ShowsController < ApplicationController
  # GET /shows.json
  def index
    respond_to do |format|
      format.json do
        begin
          shows = policy_scope(Show).includes(:videos).all
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
          authorize(show, :show?)

          render json: { data: show }
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

  # POST /shows.json
  def create
    respond_to do |format|
      format.json do
        begin
          show = Show.new(show_params)
          authorize(show, :create?)
          show.save!

          render json: { data: show }
        rescue ActiveRecord::RecordInvalid
          render json: { errors: show.errors, full_errors: show.errors.full_messages },
                 status: :unprocessable_entity
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

  # PUT /shows/:id.json
  def update
    respond_to do |format|
      format.json do
        begin
          show = Show.find(params[:id])
          authorize(show, :update?)
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

  # DELETE /shows/:id
  def destroy
    respond_to do |format|
      format.json do
        begin
          show = Show.find(params[:id])
          authorize(show, :destroy?)
          show.destroy

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
  def show_params
    params.fetch(:show, {}).permit(:title, :air_date, :hosts)
  end
end
