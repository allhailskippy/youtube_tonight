class VideoShowSection < SitePrism::Section
  element :thumbnail, "video-show .video-thumbnail"
  element :title, ".video-title"
  element :channel, ".video-channel"
  element :duration, ".video-duration"
  element :start_at, ".video-start"
  element :end_at, ".video-end"

  element :preview_start, ".preview-start"
  element :preview_stop, ".preview-stop"

  element :start_broadcasting, ".start-broadcasting"
  element :stop_broadcasting, ".stop-broadcasting"

  element :edit, ".edit"
  element :delete, ".delete"

  element :select_result, ".select-result"
end
