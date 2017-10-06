class AddImportingVideosToPlaylists < ActiveRecord::Migration[4.2]
  def change
    add_column :playlists, :importing_videos, :boolean, default: false
  end
end
