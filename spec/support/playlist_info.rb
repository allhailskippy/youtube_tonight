class PlaylistInfoSection < SitePrism::Section
  element :playlist_image, '.playlist-image'
  element :playlist_id, '.playlist-id'
  element :title, '.playlist-title'
  element :video_count, '.playlist-video-count'
end
