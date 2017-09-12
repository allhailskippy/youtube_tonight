class VideosIndexPage < SitePrism::Page
  set_url "/app#/videos/playlists/{playlist_id}"

  element :reimport_videos, "#reimport-videos"
  element :back, "#back"

  sections :rows, "#videos .video-row" do
    element :thumbnail, "video-show .video-thumbnail"
    element :title, ".video-title"
    element :channel, ".video-channel"
    element :duration, ".video-duration"
    element :start_at, ".video-start"
    element :end_at, ".video-end"

    element :preview_start, ".preview-start"
    element :preview_stop, ".preview-stop"
  end

  section :user_info, UserInfoSection, ".sidebar user-info"
  section :playlist_info, PlaylistInfoSection, ".sidebar playlist-info"
  section :pagination_top, PaginationSection, "#pagination-top"
  section :pagination_bottom, PaginationSection, "#pagination-bottom"

  def find_row(video)
    rows.find{|row| row.root_element['id'] == "video_#{video.id}" }
  end
end
