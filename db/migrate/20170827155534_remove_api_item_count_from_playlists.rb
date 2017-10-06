class RemoveApiItemCountFromPlaylists < ActiveRecord::Migration[4.2]
  def change
    remove_column :playlists, :api_item_count
  end
end
