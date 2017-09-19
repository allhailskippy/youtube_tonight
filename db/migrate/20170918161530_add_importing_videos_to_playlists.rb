class AddImportingVideosToPlaylists < ActiveRecord::Migration
  def change
    add_column :playlists, :importing_videos, :boolean, default: false
  end
end
