class Playlist < ActiveRecord::Base
  model_stamper

  ##
  # Relationships
  #
  belongs_to :user
  has_many :playlist_items, :dependent => :destroy

  # Here for consistency
  def self.as_json_hash
    {}
  end

  def self.import_all(user = nil)
    user ||= Authorization.current_user

    # Get the list of playlists from YouTube
    playlists = YoutubeApi.get_playlists(user)

    # Clean out any playlists that no longer exist
    new_ids = playlists.values.collect{|p| p[:playlist_id] }
    current_ids = user.playlists.collect(&:api_playlist_id)
    user.playlists.where(api_playlist_id: (current_ids - new_ids)).destroy_all

    # Create/update existing playlists
    playlists.each do |list, details|
      playlist = Playlist
        .where(user_id: user.id, api_playlist_id: details[:playlist_id])
        .first_or_initialize(
          user_id: user.id,
          api_playlist_id: details[:playlist_id],
        )
      playlist.api_title = list.to_s.titleize
      playlist.api_item_count = details[:video_count].to_i
      playlist.creator_id = user.id
      playlist.updater_id = user.id

      playlist.save! if playlist.changed?
    end
    playlists
  end

  def import_videos
    user ||= Authorization.current_user

    # Get all videos for the current playlist from YouTube
    videos = YoutubeApi.get_videos_for_playlist(api_playlist_id, user)

    # Clear out any videos that no longer exist
    new_ids = videos.collect{|v| v[:video_id]}
    current_ids = playlist_items.collect(&:api_video_id)
    playlist_items.where(api_video_id: (current_ids - new_ids)).destroy_all

    # Create/update existing videos
    videos.each do |video|
      item = PlaylistItem
        .where(
          playlist_id: id,
          api_video_id: video[:video_id],
        )
        .first_or_initialize
      item.api_title = video[:title]
      item.api_thumbnail_medium_url = video[:thumbnail_medium_url]
      item.api_thumbnail_default_url = video[:thumbnail_default_url]
      item.api_thumbnail_high_url = video[:thumbnail_high_url]
      item.position = video[:position]
      item.creator_id = user.id
      item.updater_id = user.id

      item.save if item.changed?
    end

    playlist_items.reload
    playlist_items
  end
end
