class PlaylistsController < ApplicationController
  # GET /playlists.json
  def index
    respond_to do |format|
      format.json do
        begin
          params[:q] ||= {}
          params[:q][:user_id_eq] = current_user.id if params[:q][:user_id_eq].blank?
          params[:q][:s] ||= 'id desc'
          params[:per_page] ||= '10'
          params[:page] ||= '1'
          # Prevent pagination from being 0 or lower
          params[:page] = params[:page].to_i < 1 ? '1' : params[:page]
          params[:per_page] = params[:per_page].to_i < 1 ? '1' : params[:per_page]

          search = Playlist.with_permissions_to(:index).search(params[:q])
          playlists = search.result.paginate(:page => params[:page], :per_page => params[:per_page])

          render json: {
            page: params[:page],
            per_page: params[:per_page],
            total: playlists.total_entries,
            total_pages: playlists.total_pages,
            offset: playlists.offset,
            data: playlists
          }
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: e.to_s },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # GET /playlist/:id.json
  def show
    respond_to do |format|
      format.json do
        begin
          playlist = Playlist.find(params[:id])

          # Used to differentiate between not found and not authorized
          permitted_to!(:show, playlist)

          render json: { data: playlist }
        rescue ActiveRecord::RecordNotFound
          render json: { errors: 'Not Found' },
                 status: :not_found
        rescue Authorization::NotAuthorized, Authorization::AttributeAuthorizationError
          render json: { errors: 'Unauthorized' },
                 status: :unauthorized
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: e.to_s },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # POST /playlists.json
  def create
    respond_to do |format|
      format.json do
        begin
          user = params[:user_id].present? ? User.find(params[:user_id]) : current_user

          # Permission check
          permitted_to!(:import_playlists, user)

          playlists = user.import_playlists
          render json: { data: playlists }
        rescue Authorization::NotAuthorized, Authorization::AttributeAuthorizationError
          render json: { errors: 'Unauthorized' },
                 status: :unauthorized
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: e.to_s.titleize },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /playlists/:id.json
  def update
    respond_to do |format|
      format.json do
        begin
          playlist = Playlist.find(params[:id])

          # Used to differentiate between not found and not authorized
          permitted_to!(:manage, playlist)

          videos = VideoImportWorker.perform_async(playlist.id)

          render json: { data: videos }
        rescue ActiveRecord::RecordNotFound
          render json: { errors: 'Not Found' },
                 status: :not_found
        rescue Authorization::NotAuthorized, Authorization::AttributeAuthorizationError
          render json: { errors: 'Unauthorized' },
                 status: :unauthorized
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: e.to_s.titleize },
                 status: :unprocessable_entity
        end
      end
    end
  end
end
