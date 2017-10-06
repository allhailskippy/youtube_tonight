class RenamePlaylistItemsCountToVideoCount < ActiveRecord::Migration[4.2]
  def change
    rename_column :playlists, :playlist_items_count, :video_count
  end
end
