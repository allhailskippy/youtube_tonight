class VideoPlayerController < WebsocketRails::BaseController
  def load
    player_id = message[:player_id]
    video = Video.find(message[:video_id])
    WebsocketRails[:video_player].trigger(:load, {:video_id => video.id, :player_id => message["player_id"] })
  end

  def ready
    WebsocketRails[:video_player].trigger(:ready, { :video_id => message["video_id"], :player_id => message["player_id"] })
  end

  def play
    WebsocketRails[:video_player].trigger(:play, { :video_id => message["video_id"], :player_id => message["player_id"] })
  end

  def pause
    WebsocketRails[:video_player].trigger(:pause, { :video_id => message["video_id"], :player_id => message["player_id"] })
  end

  def stop
    WebsocketRails[:video_player].trigger(:stop, { :video_id => message["video_id"], :player_id => message["player_id"] })
  end

  def mute
  end

  def unmute
  end

  def setVolume
  end
end
