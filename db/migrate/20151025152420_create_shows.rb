class CreateShows < ActiveRecord::Migration[4.2]
  def up
    create_table :shows do |t|
      t.date :air_date
      t.string :title
      t.userstamps
      t.timestamps
      t.datetime :deleted_at, :default => nil
    end
  end

  def down
    drop_table :shows
  end
end
