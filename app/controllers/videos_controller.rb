class VideosController < ApplicationController
  before_filter :set_class_variables

  # GET /videos.json
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

  # GET /videos/:id.json
  def show
    respond_to do |format|
      begin
        @video = Video.find(params[:id])
        format.json do
          render json: {
            data: @video.as_json
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

  # POST /videos.json
  def create
    respond_to do |format|
      begin
        # Create
        @video = scoped.build(video_params)

        permitted_to!(:create, @video)

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
        @video.update_attributes!(video_params)
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

  # DELETE /videos/:id
  def destroy
    respond_to do |format|
      begin
        @video = scoped.find(params[:id])
        @video.destroy
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
    if @show
      @show.videos.where(nil)
    else
      Video.scoped
    end
  end

  # Class Variables
  def set_class_variables
    params[:q] ||= {}

    @show = Show.find(params[:show_id]) rescue nil
  end

  def video_params
    params.require(:video).permit(
      :title, :link, :show_id, :start_time, :end_time, :sort_order,
      :api_video_id, :api_published_at, :api_channel_id, :api_channel_title,
      :api_description, :api_thumbnail_medium_url, :api_thumbnail_default_url,
      :api_thumbnail_high_url, :api_title, :api_duration, :api_duration_seconds
    )
  end
end
