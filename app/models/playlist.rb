class Playlist < ActiveRecord::Base
  model_stamper

  ##
  # Relationships
  #
  belongs_to :user
  has_many :videos, dependent: :destroy, as: :parent

  ##
  # Methods
  #
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
    yt_videos = YoutubeApi.get_videos_for_playlist(api_playlist_id, user)

    # Clear out any videos that no longer exist
    new_ids = yt_videos.collect{|v| v[:video_id]}
    current_ids = videos.collect(&:api_video_id)
    videos.where(api_video_id: (current_ids - new_ids)).destroy_all

    # Create/update existing videos
    yt_videos.each do |v|
      video = Video
        .where(
          parent_id: id,
          parent_type: 'Playlist',
          api_video_id: v[:video_id]
        )
        .first_or_initialize
      video.title = v[:title]
      video.api_title = v[:title]
      video.api_thumbnail_medium_url = v[:thumbnail_medium_url]
      video.api_thumbnail_default_url = v[:thumbnail_default_url]
      video.api_thumbnail_high_url = v[:thumbnail_high_url]
      video.link = "https://www.youtube.com/v/#{v[:video_id]}"
      video.position = v[:position]
      video.creator_id = user.id
      video.updater_id = user.id

      video.save! if video.changed?
    end

    videos.reload
    videos
  end
end
