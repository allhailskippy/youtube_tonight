class PlaylistsController < ApplicationController
  # GET /playlist/:id.json
  def show
    respond_to do |format|
      begin
        @playlist = Playlist.with_permissions_to(:read).find(params[:id])
        format.json do
          render json: { data: @playlist.as_json(Playlist.as_json_hash) }
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

  # GET /playlists
  # GET /playlists.json
  def index
    respond_to do |format|
      format.json do
        params[:q] ||= {}
        params[:q][:user_id_eq] = current_user.id if params[:q][:user_id_eq].blank?
        params[:q][:s] ||= 'id desc'
        params[:per_page] ||= '10'
        params[:page] ||= '1'
        # Prevent pagination from being 0 or lower
        params[:page] = params[:page].to_i < 1 ? '1' : params[:page]
        params[:per_page] = params[:per_page].to_i < 1 ? '1' : params[:per_page]

        search = Playlist.with_permissions_to(:read).search(params[:q])
        playlists = search.result.paginate(:page => params[:page], :per_page => params[:per_page])

        render json: {
          page: params[:page],
          per_page: params[:per_page],
          total: playlists.total_entries,
          total_pages: playlists.total_pages,
          offset: playlists.offset,
          data: playlists.as_json(Playlist.as_json_hash)
        }
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
          playlist = Playlist.with_permissions_to(:manage).find(params[:id])
          videos = VideoImportWorker.perform_async(playlist.id)

          render json: { data: videos }
        rescue Exception => e
          NewRelic::Agent.notice_error(e)
          render json: { errors: e.to_s.titleize },
                 status: :unprocessable_entity
        end
      end
    end
  end
end
