class PlaylistInfoSection < SitePrism::Section
  element :playlist, '.playlist-image'
  element :id, '.playlist-id'
  element :title, '.playlist-title'
  element :video_count, '.playlist-video-count'
end
