class VideoPlayerController < WebsocketRails::BaseController
  PlayerEvents.events.each do |e|
    define_method("#{e}") do
      WebsocketRails[:video_player].trigger(e, message)
    end
  end
end
