class PlaylistImportWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :playlists

  def perform(user_id)
    begin
      Authorization.current_user = User.find(3)
      user = User.find(user_id)
      playlists = Playlist.import_all(user)
      user.playlists.reload.each do |playlist|
        playlist.import_videos
      end
    rescue Exception => e
      NewRelic::Agent.notice_error(e)
      raise
    end
  end
end
