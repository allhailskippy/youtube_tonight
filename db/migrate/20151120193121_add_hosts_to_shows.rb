class AddHostsToShows < ActiveRecord::Migration
  def change
    change_table(:shows) do |t|
      t.string :hosts
    end
  end
end
