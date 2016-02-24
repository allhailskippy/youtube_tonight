ImportPlaylistsJob = Struct.new(:user) do
  def perform
    Authorization.current_user = user

    user.update_attribute(:importing_playlists, true)

    playlists = YoutubeApi.get_playlists
    
    # Transaction prevents us from losing existing
    # playlists in the event stuff goes wrong with
    # the saving of the new ones
    ActiveRecord::Base.transaction do
      # Clear out existing lists
      user.playlists.destroy_all

      playlists.each do |list, details|
        playlist = Playlist.new(
          user_id: user.id,
          api_playlist_id: details[:playlist_id],
          api_title: list.to_s.titleize,
          creator_id: user.id,
          updater_id: user.id
        )
        playlist.playlist_items = details[:videos].collect do |video|
          PlaylistItem.new(
            api_video_id: video[:video_id],
            api_title: video[:title],
            api_thumbnail_medium_url: video[:thumbnail_medium_url],
            api_thumbnail_default_url: video[:thumbnail_default_url],
            api_thumbnail_high_url: video[:thumbnail_high_url],
            position: video[:position],
            creator_id: user.id,
            updater_id: user.id
          )
        end
        playlist.save!
      end
    end
    
    user.update_attribute(:importing_playlists, false)
  end
end
