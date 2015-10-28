class CreateShows < ActiveRecord::Migration
  def up
    create_table :shows do |t|
      t.date :air_date
      t.string :title
      t.userstamps
      t.timestamps
      t.datetime :deleted_at, :default => nil
    end
    Show.create_versioned_table
  end

  def down
    drop_table :shows
    drop_table :show_versions
  end
end
