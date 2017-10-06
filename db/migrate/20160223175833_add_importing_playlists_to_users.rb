class AddImportingPlaylistsToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table(:users) do |t|
      t.boolean :importing_playlists, :default => false
    end
  end
end
