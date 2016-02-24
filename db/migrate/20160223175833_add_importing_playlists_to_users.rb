class AddImportingPlaylistsToUsers < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.boolean :importing_playlists, :default => false
    end
  end
end
