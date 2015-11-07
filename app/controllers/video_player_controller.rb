class VideoPlayerController < WebsocketRails::BaseController
  def load
    begin
      video = Video.find(message[:video_id])
      trigger_success({ :message => video.api_video_id })
    rescue ActiveRecord::RecordNotFound
      trigger_failure({ :message => 'Video not found' })
    rescue Exception => e
      trigger_failure({ :message => e.to_s })
    end
    WebsocketRails[:video_player].trigger(:load, {:video_id => video.id })
  end

  def ready
    WebsocketRails[:video_player].trigger(:ready, { :video_id => message["video_id"], :video_key => message["video_key"]})
  end

  def play
    WebsocketRails[:video_player].trigger(:play, { :video_id => message["video_id"], :video_key => message["video_key"]})
  end

  def pause
    WebsocketRails[:video_player].trigger(:pause, { :video_id => message["video_id"], :video_key => message["video_key"]})
  end

  def stop
    WebsocketRails[:video_player].trigger(:stop, { :video_id => message["video_id"], :video_key => message["video_key"]})
  end

  def mute
  end

  def unmute
  end

  def setVolume
  end
end
