class PlaylistsController < ApplicationController
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

        search = policy_scope(Playlist).search(params[:q])
        playlists = search.result.paginate(:page => params[:page], :per_page => params[:per_page])

        render json: {
          page: params[:page],
          per_page: params[:per_page],
          total: playlists.total_entries,
          total_pages: playlists.total_pages,
          offset: playlists.offset,
          data: playlists
        }
      end
    end
  end

  # GET /playlist/:id.json
  def show
    respond_to do |format|
      format.json do
        playlist = Playlist.find(params[:id])

        # Used to differentiate between not found and not authorized
        authorize(playlist, :show?)

        render json: { data: playlist }
      end
    end
  end

  # POST /playlists.json
  def create
    respond_to do |format|
      format.json do
        user = params[:user_id].present? ? User.find(params[:user_id]) : current_user

        # Permission check
        authorize(user, :import_playlists?)

        playlists = user.import_playlists
        render json: { data: playlists }
      end
    end
  end

  # PUT /playlists/:id.json
  def update
    respond_to do |format|
      format.json do
        playlist = Playlist.find(params[:id])

        # Used to differentiate between not found and not authorized
        authorize(playlist, :manage?)

        videos = VideoImportWorker.perform_async(playlist.id)

        render json: { data: videos }
      end
    end
  end
end
