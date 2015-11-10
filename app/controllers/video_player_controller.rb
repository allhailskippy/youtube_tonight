class VideoPlayerController < WebsocketRails::BaseController
  def load
    player_id = message[:player_id]
    video = Video.find(message[:video_id])
    WebsocketRails[:video_player].trigger(:load, {
      :video_id => video.id,
      :player_id => message["player_id"]
    })
  end

  def ready
    WebsocketRails[:video_player].trigger(:ready, {
      :video_id => message["video_id"],
      :player_id => message["player_id"]
    })
  end

  def player_ready
    WebsocketRails[:video_player].trigger(:player_ready, {
      :video_id => message["video_id"],
      :player_id => message["player_id"]
    })
  end

  def play
    WebsocketRails[:video_player].trigger(:play, {
      :video_id => message["video_id"],
      :player_id => message["player_id"]
    })
  end

  def pause
    WebsocketRails[:video_player].trigger(:pause, {
      :video_id => message["video_id"],
      :player_id => message["player_id"]
    })
  end

  def stop
    WebsocketRails[:video_player].trigger(:stop, {
      :video_id => message["video_id"],
      :player_id => message["player_id"]
    })
  end

  def mute
    resp = {
      :video_id => message["video_id"],
      :player_id => message["player_id"]
    }
    trigger_success resp
    WebsocketRails[:video_player].trigger(:mute, resp)
  end

  def unmute
    resp = {
      :video_id => message["video_id"],
      :player_id => message["player_id"]
    }
    trigger_success resp
    WebsocketRails[:video_player].trigger(:unmute, resp)
  end

  def set_volume
    WebsocketRails[:video_player].trigger(:set_volume, {
      :volume => message["volume"],
      :video_id => message["video_id"],
      :player_id => message["player_id"]
    })
  end

  def state_change
    WebsocketRails[:video_player].trigger(:state_change, {
      :video_id => message["video_id"],
      :player_id => message["player_id"],
      :state => message["state"]
    })
  end
end
