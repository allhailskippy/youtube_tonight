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
#      t.userstamps
      t.timestamps
    end
  end

  def down
    drop_table :videos
  end
end
