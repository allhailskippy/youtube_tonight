class VideoPlayerChannel < ApplicationCable::Channel
  def subscribed
    User.stamper = current_user

    player_id = params[:data][:player_id]
    broadcast_id = params[:data][:broadcast_id]
    live = !!params[:data][:live]

    # Transaction prevents race condition where
    # two of the same record get created
    unless player_id == 'monitor'
      ActiveRecord::Base.transaction do
        Player.find_or_create_by({
          user_id: current_user.id,
          player_id: player_id,
          broadcast_id: broadcast_id,
          live: live
        })
      end
    end

    broadcast_id = params[:data][:broadcast_id]
    stream = broadcast_id.present? ? "broadcast:#{broadcast_id}" : player_id
    stream_for stream

    if live
      stream = "broadcast:#{broadcast_id}"
      VideoPlayerChannel.broadcast_to(stream, { action: 'registered', message: { player_id: player_id, broadcast_id: broadcast_id } })
    end
  end

  def unsubscribed
    player_id = params[:data][:player_id]
    broadcast_id = params[:data][:broadcast_id]
    unless player_id == 'monitor'
      if player = Player.where({
        user_id: current_user.id,
        player_id: player_id,
        broadcast_id: broadcast_id
      }).first
        # Let the other open pages know that we closed a live broadcast window
        if player.live
          stream = "broadcast:#{player.broadcast_id}"
          VideoPlayerChannel.broadcast_to(stream, { action: 'unregistered', message: { player_id: player_id, broadcast_id: broadcast_id } })
        end
        player.destroy
      end
    end
  end

  PlayerEvents.events.each do |e|
    define_method("#{e}") do |message|
      player_ids = []
      player_id = params[:data][:player_id]
      broadcast_id = params[:data][:broadcast_id]
      if(message[:player_id] == 'all')
        # Typically used when deleting a video and need to notify
        # all players that the event occured. Not used often
        player_ids = Player.all.collect(&:player_id)
      elsif player_id == 'monitor'
        player_ids = ["broadcast:#{broadcast_id}"]
      elsif player = Player.where(player_id: player_id).first
        # Players with a broadcast_id all go to the same stream
        # other players all get their own
        player_ids = [(player.broadcast_id.present? ? "broadcast:#{player.broadcast_id}" : player.player_id)]
      end
      player_ids.each do |player_id|
        VideoPlayerChannel.broadcast_to(player_id, message)
      end
    end
  end
end
