class VideoPlayerController < WebsocketRails::BaseController
  def load
    WebsocketRails[:video_player].trigger(:load, {
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    })
  end

  def ready
    WebsocketRails[:video_player].trigger(:ready, {
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    })
  end

  def not_ready
    WebsocketRails[:video_player].trigger(:not_ready, {
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    })
  end

  def play
    WebsocketRails[:video_player].trigger(:play, {
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    })
  end

  def pause
    WebsocketRails[:video_player].trigger(:pause, {
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    })
  end

  def stop
    WebsocketRails[:video_player].trigger(:stop, {
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    })
  end

  def mute
    resp = {
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    }
    trigger_success resp
    WebsocketRails[:video_player].trigger(:mute, resp)
  end

  def unmute
    resp = {
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    }
    trigger_success resp
    WebsocketRails[:video_player].trigger(:unmute, resp)
  end

  def set_volume
    WebsocketRails[:video_player].trigger(:set_volume, {
      :volume => message["volume"],
      :video => message["video"],
      :player_id => message["player_id"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    })
  end

  def state_change
    WebsocketRails[:video_player].trigger(:state_change, {
      :video => message["video"],
      :player_id => message["player_id"],
      :state => message["state"],
      :sender_id => message["sender_id"],
      :show_id => message["show_id"]
    })
  end
end
