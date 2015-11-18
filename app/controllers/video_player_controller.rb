class VideoPlayerController < WebsocketRails::BaseController
   events = [
    :play, :playing,
    :stop, :stopped,
    :pause, :paused,
    :mute, :muted,
    :unmute, :unmuted,
    :currently_playing
  ]

  events.each do |e|
    define_method("#{e}") do
      WebsocketRails[:video_player].trigger(e, message)
    end
  end
end
