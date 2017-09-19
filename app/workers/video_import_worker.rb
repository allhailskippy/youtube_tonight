class VideoImportWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :playlists

  def perform(playlist_id)
    begin
      Authorization.current_user = User.find(SYSTEM_ADMIN_ID)
      playlist = Playlist.find(playlist_id)
      unless playlist.importing_videos
        playlist.import_videos
      end
    rescue Exception => e
      NewRelic::Agent.notice_error(e)
      raise
    end
  end
end
