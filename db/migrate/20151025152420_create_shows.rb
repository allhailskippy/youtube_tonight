class CreateShows < ActiveRecord::Migration
  def up
    create_table :shows do |t|
      t.date :air_date
      t.string :title
      t.timestamps
    end

    add_column :videos, :show_id, :integer, :after => :id
  end

  def down
    drop_table :shows
    remove_column :videos, :show_id
  end
end
