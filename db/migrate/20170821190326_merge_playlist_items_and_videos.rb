class MergePlaylistItemsAndVideos < ActiveRecord::Migration[4.2]
  def up
    rename_column :videos, :show_id, :parent_id
    add_column :videos, :parent_type, :string
    add_column :videos, :position, :integer, default: nil

    sql = "UPDATE videos SET parent_type='Show'"
    execute(sql)

    drop_table :playlist_items rescue nil

  end

  def down
    create_table :playlist_items do |t|
      t.integer :playlist_id
      t.string :api_video_id
      t.string :api_title
      t.string :api_thumbnail_medium_url
      t.string :api_thumbnail_default_url
      t.string :api_thumbnail_high_url
      t.integer :position
      t.userstamps
      t.timestamps
    end

    sql = "DELETE from VIDEOS where parent_type = 'Playlist'"
    execute(sql)

    remove_column :videos, :position
    remove_column :videos, :parent_type
    rename_column :videos, :parent_id, :show_id
  end
end
