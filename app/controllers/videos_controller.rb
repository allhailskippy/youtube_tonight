class VideosController < ApplicationController
  before_filter :set_class_variables

  # GET /videos
  # GET /videos.json
  def index
    respond_to do |format|
      format.html
      format.json do
        params[:q] ||= {}
        params[:q][:user_id_eq] = current_user.id if params[:q][:user_id_eq].blank?
        params[:q][:s] ||= 'id desc'
        params[:per_page] ||= 10
        params[:page] ||= 1
        # Prevent page from being 0 or lower
        params[:page] = params[:page].to_i < 1 ? 1 : params[:page]

        search = scoped.search(params[:q])
        videos = search.result.paginate(:page => params[:page], :per_page => params[:per_page])

        render json: {
          page: params[:page],
          per_page: params[:per_page],
          total: videos.total_entries,
          total_pages: videos.total_pages,
          offset: videos.offset,
          data: videos.as_json(Video.as_json_hash)
        }
      end
    end
  end

  # GET /videos/:id.json
  def show
    respond_to do |format|
      begin
        video = Video.with_permissions_to(:read).find(params[:id])
        format.json do
          render json: { data: video.as_json }
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

  # POST /videos.json
  def create
    respond_to do |format|
      begin
        video = scoped.build(video_params)
        permitted_to!(:create, video)
        video.save!

        format.json do
          render json: video.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: { errors: video.errors, full_errors: video.errors.full_messages },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /videos/:id.json
  def update
    video = scoped.find(params[:id])

    respond_to do |format|
      begin
        permitted_to!(:update, video)
        video.update_attributes!(video_params)

        format.json do
          render json: video.as_json
        end
      rescue ActiveRecord::RecordInvalid
        format.json do
          render json: { errors: video.errors, full_errors: video.errors.full_messages },
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

  # DELETE /videos/:id
  def destroy
    respond_to do |format|
      begin
        video = scoped.find(params[:id])
        permitted_to!(:delete, video)
        video.destroy

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
    if @parent
      @parent.videos
    else
      Video.with_permissions_to(:read).all
    end
  end

  # Class Variables
  def set_class_variables
    params[:q] ||= {}

    @parent = nil
    if params[:show_id].present?
      @parent = Show.with_permissions_to(:read).find(params[:show_id])
    elsif params[:playlist_id].present?
      @parent = Playlist.with_permissions_to(:read).find(params[:playlist_id])
    end
  end

  def video_params
    params.fetch(:video, {}).permit(
      :title, :link, :start_time, :end_time, :position,
      :api_video_id, :api_published_at, :api_channel_id, :api_channel_title,
      :api_description, :api_thumbnail_medium_url, :api_thumbnail_default_url,
      :api_thumbnail_high_url, :api_title, :api_duration, :api_duration_seconds,
      :parent_id, :parent_type
    )
  end
end
