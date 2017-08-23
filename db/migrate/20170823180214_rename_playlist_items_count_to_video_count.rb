class RenamePlaylistItemsCountToVideoCount < ActiveRecord::Migration
  def change
    rename_column :playlists, :playlist_items_count, :video_count
  end
end
