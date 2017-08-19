class AddColumnsToPlaylists < ActiveRecord::Migration
  def change
    change_table(:playlists) do |t|
      t.integer :api_item_count, after: :api_title
      t.integer :playlist_items_count, after: :api_item_count, default: 0
    end
  end
end
