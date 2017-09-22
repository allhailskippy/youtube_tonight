class ParentException < StandardError
end

class VideosController < ApplicationController
  # GET /videos.json
  def index
    respond_to do |format|
      format.json do
        begin
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
        rescue ParentException
          render json: { errors: ['Expected Show or Playlist to be provided'] },
                 status: :expectation_failed
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # GET /videos/:id.json
  def show
    respond_to do |format|
      format.json do
        begin
          video = scoped.find(params[:id])
          authorize(video, :show?)

          render json: { data: video}
        rescue ParentException
          render json: { errors: ['Expected Show or Playlist to be provided'] },
                 status: :expectation_failed
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue Pundit::NotAuthorizedError
          render json: { errors: ['Unauthorized'] },
                 status: :not_found
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # POST /videos.json
  def create
    respond_to do |format|
      format.json do
        begin
          video = scoped.build(video_params)
          authorize(video, :create?)
          video.save!

          render json: { data: video }
        rescue ParentException
          render json: { errors: ['Expected Show or Playlist to be provided'] },
                 status: :expectation_failed
        rescue ActiveRecord::RecordInvalid
          render json: { errors: video.errors, full_errors: video.errors.full_messages },
                 status: :unprocessable_entity
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue Pundit::NotAuthorizedError
          render json: { errors: ['Unauthorized'] },
                 status: :not_found
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /videos/:id.json
  def update
    respond_to do |format|
      format.json do
        begin
          video = scoped.find(params[:id])
          authorize(video, :update?)

          render json: { data: video }
        rescue ParentException
          render json: { errors: ['Expected Show or Playlist to be provided'] },
                 status: :expectation_failed
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue ActiveRecord::RecordInvalid
          render json: { errors: video.errors, full_errors: video.errors.full_messages },
                 status: :unprocessable_entity
        rescue Pundit::NotAuthorizedError
          render json: { errors: ['Unauthorized'] },
                 status: :not_found
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: [e.to_s.titleize] },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /videos/:id
  def destroy
    respond_to do |format|
      format.json do
        begin
          video = scoped.find(params[:id])
          authorize(video, :destroy?)
          video.destroy

          render json: { data: {} }
        rescue ParentException
          render json: { errors: ['Expected Show or Playlist to be provided'] },
                 status: :expectation_failed
        rescue ActiveRecord::RecordNotFound
          render json: { errors: ['Not Found'] },
                 status: :not_found
        rescue Pundit::NotAuthorizedError
          render json: { errors: ['Unauthorized'] },
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
