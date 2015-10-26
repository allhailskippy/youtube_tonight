class ShowsController < ApplicationController
  # GET /shows
  # GET /shows.json
  def index
    @shows = Show.order("id desc").all
    respond_to do |format|
      format.html
      format.json do
        render json: {
          data: @shows.as_json
        }
      end
    end
  end

  # POST /shows.json
  def create
    respond_to do |format|
      begin
        # Create
        @show = scoped.build(params[:show])

        # TODO: Permissions
        # permitted_to!(:create, @show)

        # Save Show
        @show.save!

        format.json do
          render json: @show.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: {
              errors: @show.errors,
              full_errors: @show.errors.full_messages
            },
            status: :unprocessable_entity
        end
      end
    end
  end

private
  def scoped
    Show.scoped
  end
end
