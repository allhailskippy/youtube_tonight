class VideosController < ApplicationController
  # GET /videos.json
  def index
    respond_to do |format|
      format.json do
        params[:q] ||= {}
        params[:q][:s] ||= 'id desc'
        params[:per_page] ||= '10'
        params[:page] ||= '1'

        # Prevent pagination from being 0 or lower
        params[:page] = params[:page].to_i < 1 ? '1' : params[:page]
        params[:per_page] = params[:per_page].to_i < 1 ? '1' : params[:per_page]

        search = scoped.search(params[:q])
        videos = search.result.paginate(:page => params[:page], :per_page => params[:per_page])

        render json: {
          page: params[:page],
          per_page: params[:per_page],
          total: videos.total_entries,
          total_pages: videos.total_pages,
          offset: videos.offset,
          data: videos
        }
      end
    end
  end

  # GET /videos/:id.json
  def show
    respond_to do |format|
      format.json do
        video = scoped.find(params[:id])
        authorize(video, :show?)

        render json: { data: video}
      end
    end
  end

  # POST /videos.json
  def create
    respond_to do |format|
      format.json do
        video = scoped.build(video_params)
        authorize(video, :create?)
        video.save!

        render json: { data: video }
      end
    end
  end

  # PUT /videos/:id.json
  def update
    respond_to do |format|
      format.json do
        video = scoped.find(params[:id])
        video.assign_attributes(video_params)
        authorize(video, :update?)
        video.save!

        render json: { data: video }
      end
    end
  end

  # DELETE /videos/:id
  def destroy
    respond_to do |format|
      format.json do
        video = scoped.find(params[:id])
        authorize(video, :destroy?)
        video.destroy

        render json: { data: {} }
      end
    end
  end

private
  def scoped
    parent = if params[:show_id].present?
      policy_scope(Show).find(params[:show_id])
    elsif params[:playlist_id].present?
      policy_scope(Playlist).find(params[:playlist_id])
    else
      raise ParentException
    end
    parent.videos
  end

  def video_params
    params.fetch(:video, {}).permit(
      :id, :title, :link, :start_time, :end_time, :position,
      :api_video_id, :api_published_at, :api_channel_id, :api_channel_title,
      :api_description, :api_thumbnail_medium_url, :api_thumbnail_default_url,
      :api_thumbnail_high_url, :api_title, :api_duration, :api_duration_seconds,
      :parent_id, :parent_type
    )
  end
end
