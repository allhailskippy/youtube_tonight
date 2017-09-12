class PlaylistsIndexPage < SitePrism::Page
  set_url "/#/playlists"

  element :playlists, "#playlists"
  element :reimport_playlists, ".reimport"
  element :search, ".search-query"
  element :back, "#back"

  section :user_info, UserInfoSection, ".sidebar user-info"

  sections :rows, "#playlists tbody tr" do
    element :thumbnail, ".playlist-image"
    element :title, ".title"
    element :description, ".description"
    element :video_count, ".video-count"

    section :sec_actions, ".actions" do
      element :refresh_videos, ".refresh-videos"
      element :videos, "a.videos"
    end
  end

  section :pagination, PaginationSection, "#tasty-pagination"

  def find_row(playlist)
    rows.find{|row| row.root_element['id'] == "playlist_#{playlist.id}" }
  end
end

# Same page, but with a user id in the url
class PlaylistsUserIndexPage < PlaylistsIndexPage
  set_url "/#/users/{user_id}/playlists"
end
