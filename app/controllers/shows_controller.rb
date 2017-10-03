class ShowsController < ApplicationController
  # GET /shows.json
  def index
    respond_to do |format|
      format.json do
        policy_scope(Show).includes(:videos).all
        shows = policy_scope(Show).includes(:videos).all
        render json: { data: shows }
      end
    end
  end

  # GET /shows/:id.json
  def show
    respond_to do |format|
      format.json do
        show = Show.find(params[:id])
        authorize(show, :show?)

        render json: { data: show }
      end
    end
  end

  # POST /shows.json
  def create
    respond_to do |format|
      format.json do
        show = Show.new(show_params)
        authorize(show, :create?)
        show.save!

        render json: { data: show }
      end
    end
  end

  # PUT /shows/:id.json
  def update
    respond_to do |format|
      format.json do
        show = Show.find(params[:id])
        authorize(show, :update?)
        show.update_attributes!(show_params)

        # Gets rid of user/hosts cache values
        show = Show.find(show.id)

        render json: { data: show }
      end
    end
  end

  # DELETE /shows/:id
  def destroy
    respond_to do |format|
      format.json do
        show = Show.find(params[:id])
        authorize(show, :destroy?)
        show.destroy

        render json: { data: {} }
      end
    end
  end

private
  def show_params
    params.fetch(:show, {}).permit(:title, :air_date, :hosts)
  end
end
