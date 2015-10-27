class VideosController < ApplicationController
  before_filter :set_class_variables

  def index
    respond_to do |format|
      format.html
      format.json do
        @search = @show.videos.search(params[:q])
        @videos = @search.result.paginate(:page => params[:page], :per_page => params[:per_page])
        render json: {
          data: @videos.as_json
        }
      end
    end
  end

  # POST /videos.json
  def create
    respond_to do |format|
      begin
        # Create
        @video = scoped.build(params[:video])

        # TODO: Permissions
        # permitted_to!(:create, @video)

        # Save Video
        @video.save!

        format.json do
          render json: @video.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: {
              errors: @video.errors,
              full_errors: @video.errors.full_messages
            },
            status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /videos/:id.json
  def update
    @video = scoped.find(params[:id])

    respond_to do |format|
      begin
        @video.update_attributes!(params[:video])
        format.json do
          render json: @video.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: {
            errors: @video.errors,
            full_errors: @video.errors.full_messages
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

private
  def scoped
    if @show
      @show.videos.scoped
    else
      Video.scoped
    end
  end

  # Class Variables
  def set_class_variables
    params[:q] ||= {}

    @show = Show.find(params[:show_id]) rescue nil
  end
end
