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
  element :clear, ".clear-video"
  element :add_to_queue, "#add-to-queue"
  element :update, "#update"
  element :cancel, "#cancel"

  element :thumbnail_area, ".thumbnail-area"
end

class VideoPreviewControlSection < SitePrism::Section
  element :container, ".preview-container"
  element :slider, ".preview-slider"
  element :play, ".preview-play"
  element :pause, ".preview-pause"
  element :stop, ".preview-stop"
  element :mute, ".preview-mute"
  element :unmute, ".preview-unmute"
end

class VideosCommonPage < SitePrism::Page
  section :menu, MenuSection, "nav"
  element :back, "#back"
  elements :errors, "div[notices='notices'] .alert-danger"
  sections :rows, VideoShowSection, "#videos .video-row"
  element :preview_area, "#preview_area"
  element :broadcast_area, "#broadcast_area"
  section :preview_controls, VideoPreviewControlSection, ".preview_container video-controls"
  section :broadcast_controls, VideoPreviewControlSection, "#broadcast_area video-controls"

  def find_row(video)
    rows.find{|row| row.root_element['id'] == "video_#{video.id}" }
  end
end

class VideosPlaylistIndexPage < VideosCommonPage
  set_url "/#/playlists/{playlist_id}/videos"

  element :reimport_videos, "#reimport-videos"
  section :user_info, UserInfoSection, ".sidebar user-info"
  section :playlist_info, PlaylistInfoSection, ".sidebar playlist-info"
  section :pagination_top, PaginationSection, "#pagination-top"
  section :pagination_bottom, PaginationSection, "#pagination-bottom"
end

class VideosShowsIndexPage < VideosCommonPage
  set_url "/#/shows/{show_id}/videos"

  element :launch_broadcast, "#launch_broadcast"
  element :add_video, "#add-video"
  section :video_form, "video-form" do
    element :search, "input[name='search']"
    element :title, "input[name='title']"
    element :start_at, "input[name='start_time']"
    element :end_at, "input[name='end_time']"
  end
  sections :search_results, VideoShowSection, ".search-results"
  section :selected_video, VideoShowSection, "#selected-video"
end
