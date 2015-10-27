class Videos < ActiveRecord::Migration
  def up
    create_table :videos do |t|
      t.integer :show_id
      t.string :title
      t.text :link
      t.string :video_id
      t.string :start_time, :default => nil
      t.string :end_time, :default => nil
      t.integer :sort_order

      t.string :api_published_at
      t.string :api_channel_id
      t.string :api_channel_title
      t.text :api_description
      t.string :api_thumbnail_medium_url
      t.string :api_thumbnail_default_url
      t.string :api_thumbnail_high_url
      t.string :api_title
      t.timestamps
    end
  end

  def down
    drop_table :videos
  end
end
