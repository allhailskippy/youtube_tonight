class PlaylistsController < ApplicationController
  # GET /playlists
  # GET /playlists.json
  def index
    respond_to do |format|
      format.html
      format.json do
        params[:q] ||= {}
        params[:q][:user_id_eq] = current_user.id # Restrict to current user
        params[:q][:s] ||= 'id desc'
        params[:per_page] ||= 10
        params[:page] ||= 1
        # Prevent page from being 0 or lower
        params[:page] = params[:page].to_i < 1 ? 1 : params[:page]

        search = Playlist.search(params[:q])
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

  ##
  # Creates a delayed job that will import all of the playlists
  # for the currently logged in user
  #
  # PUT /playlists.json
  def create
    respond_to do |format|
      format.json do
        begin
          user = params[:user_id].present? ? User.find(params[:user_id]) : current_user

          raise Exception.new("already_importing") if user.importing_playlists

          # Set importing playlists so we don't double add delayed job
          current_user.update_attribute(:importing_playlists, true)

          # Start job
          Delayed::Job.enqueue(
            ImportPlaylistsJob.new(user)
          )

          render json: {
            data: 'queued'
          }
        rescue Exception => e
          render json: {
            errors: e.to_s.titleize
          }, status: 400
        end 
      end
    end
  end
end
