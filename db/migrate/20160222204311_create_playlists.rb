class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.integer :user_id
      t.string :api_playlist_id
      t.string :api_title
      t.userstamps
      t.timestamps
    end

    create_table :playlist_items do |t|
      t.integer :playlist_id
      t.string :api_video_id
      t.string :api_thumbnail_medium_url
      t.string :api_thumbnail_default_url
      t.string :api_thumbnail_high_url
      t.integer :position
      t.userstamps
      t.timestamps
    end
  end
end
