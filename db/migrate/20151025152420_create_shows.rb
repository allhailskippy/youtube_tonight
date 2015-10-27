class CreateShows < ActiveRecord::Migration
  def up
    create_table :shows do |t|
      t.date :air_date
      t.string :title
      t.timestamps
    end
  end

  def down
    drop_table :shows
  end
end
