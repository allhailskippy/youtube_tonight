class RemoveApiItemCountFromPlaylists < ActiveRecord::Migration
  def change
    remove_column :playlists, :api_item_count
  end
end
