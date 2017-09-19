class PlaylistEventsController < WebsocketRails::BaseController
  Playlist.events.each do |e|
    define_method("#{e}") do
      WebsocketRails[:playlist_events].trigger(e, message)
    end
  end
end
