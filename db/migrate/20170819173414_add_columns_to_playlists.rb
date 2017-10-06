class AddColumnsToPlaylists < ActiveRecord::Migration[4.2]
  def change
    change_table(:playlists) do |t|
      t.integer :api_item_count, after: :api_title
      t.integer :playlist_items_count, after: :api_item_count, default: 0
    end
  end
end
