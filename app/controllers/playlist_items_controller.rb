class PlaylistItemsController < ApplicationController
  # GET /playlist_items
  # GET /playlist_items.json
  def index
    respond_to do |format|
      format.html
      format.json do
        params[:q] ||= {}
        params[:q][:s] ||= 'position asc'
        params[:per_page] ||= 10
        params[:page] ||= 1
        # Prevent page from being 0 or lower
        params[:page] = params[:page].to_i < 1 ? 1 : params[:page]

        search = PlaylistItem.search(params[:q])
        playlist_items = search.result.paginate(:page => params[:page], :per_page => params[:per_page])

        render json: {
          page: params[:page],
          per_page: params[:per_page],
          total: playlist_items.total_entries,
          total_pages: playlist_items.total_pages,
          offset: playlist_items.offset,
          data: playlist_items.as_json(PlaylistItem.as_json_hash)
        }
      end
    end
  end
end
