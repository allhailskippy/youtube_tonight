class AddHostsToShows < ActiveRecord::Migration[4.2]
  def change
    change_table(:shows) do |t|
      t.string :hosts
    end
  end
end
