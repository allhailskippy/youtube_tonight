class Playlist < ActiveRecord::Base
  model_stamper

  # == Relationships ========================================================
  belongs_to :user
  has_many :videos, dependent: :destroy, as: :parent

  # == Class Methods ========================================================
  # Used for definining websocket events
  def self.events
    [:updated]
  end

  # == Instance Methods =====================================================
  def import_videos
    update_attributes!(importing_videos: true)
    # Get all videos for the current playlist from YouTube
    yt_videos = YoutubeApi.get_videos_for_playlist(api_playlist_id, user)

    # Clear out any videos that no longer exist
    new_ids = yt_videos.collect{|v| v[:video_id]}
    current_ids = videos.collect(&:api_video_id)
    videos.where(api_video_id: (current_ids - new_ids)).delete_all

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
      video.api_duration = v['duration']
      video.api_duration_seconds = v['duration_seconds']
      video.api_channel_title = v[:channel_title]
      video.api_channel_id = v[:channel_id]
      video.link = "https://www.youtube.com/v/#{v[:video_id]}"
      video.position = v[:position]
      video.creator_id = user.id
      video.updater_id = user.id

      video.save! if video.changed?
    end

    videos.reload
    update_attributes!(video_count: videos.count, importing_videos: false)

    PlaylistEventsChannel.broadcast_to(user, {action: 'updated', message: {'playlist_id': id}})

    videos
  end
end
