class MergeSortOrderAndPosition < ActiveRecord::Migration
  def up
    sql = "UPDATE videos SET position=sort_order WHERE parent_type='Playlist'"
    execute(sql)

    remove_column :videos, :sort_order
  end

  def down
    add_column :videos, :sort_order, :integer
    sql = "UPDATE videos SET sort_order=position WHERE parent_type='Playlist'"
    execute(sql)
  end
end
