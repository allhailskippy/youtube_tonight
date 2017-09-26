class VideoPlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_for 'video_player'
  end
  
  def unsubscribed
  end

  PlayerEvents.events.each do |e|
    define_method("#{e}") do |message|
      VideoPlayerChannel.broadcast_to(params["data"], message)
    end
  end
end
