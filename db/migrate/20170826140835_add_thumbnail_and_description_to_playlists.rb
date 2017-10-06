class AddThumbnailAndDescriptionToPlaylists < ActiveRecord::Migration[4.2]
  def change
    add_column :playlists, :api_description, :text
    add_column :playlists, :api_thumbnail_default_url, :string
    add_column :playlists, :api_thumbnail_default_width, :integer
    add_column :playlists, :api_thumbnail_default_height, :integer
    add_column :playlists, :api_thumbnail_medium_url, :string
    add_column :playlists, :api_thumbnail_medium_width, :integer
    add_column :playlists, :api_thumbnail_medium_height, :integer
    add_column :playlists, :api_thumbnail_high_url, :string
    add_column :playlists, :api_thumbnail_high_width, :integer
    add_column :playlists, :api_thumbnail_high_height, :integer
    add_column :playlists, :api_thumbnail_standard_url, :string
    add_column :playlists, :api_thumbnail_standard_width, :integer
    add_column :playlists, :api_thumbnail_standard_height, :integer
    add_column :playlists, :api_thumbnail_maxres_url, :string
    add_column :playlists, :api_thumbnail_maxres_width, :integer
    add_column :playlists, :api_thumbnail_maxres_height, :integer
  end
end
