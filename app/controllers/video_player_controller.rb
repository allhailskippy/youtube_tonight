class VideoPlayerController < WebsocketRails::BaseController
   events = [
    :play, :playing,
    :stop, :stopped,
    :pause, :paused,
    :mute, :muted,
    :unmute, :unmuted
  ]

  events.each do |e|
    define_method("#{e}") do
      WebsocketRails[:video_player].trigger(e, {
        :video => message["video"],
        :player_id => message["player_id"],
        :sender_id => message["sender_id"]
      })
    end
  end
end
