class VideosCommonPage < SitePrism::Page
  element :back, "#back"

  sections :rows, VideoShowSection, "#videos .video-row"

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
  end

  sections :search_results, VideoShowSection, ".search-results"
end
