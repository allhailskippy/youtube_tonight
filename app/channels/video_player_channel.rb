class VideoPlayerChannel < ApplicationCable::Channel
  def subscribed
    if player_id = params[:data][:player_id]
      ActiveRecord::Base.transaction do
        player = Player.find_or_initialize_by({ player_id: player_id, broadcast_id: params[:data][:broadcast_id] })
        player.registered_count += 1
        player.save!
      end

      broadcast_id = params[:data][:broadcast_id]
      stream_for(broadcast_id.present? ? "broadcast:#{broadcast_id}" : player_id)
    end
  end

  def unsubscribed
    player_id = params[:data][:player_id]
    if player = Player.where({ player_id: player_id }).first
      if player.registered_count == 1
        player.destroy
      else
        player.registered_count -= 1
        player.save!
      end
    end
  end

  PlayerEvents.events.each do |e|
    define_method("#{e}") do |message|
      player_ids = []
      if(message[:player_id] == 'all')
        player_ids = Player.all.collect(&:player_id)
      else
        if player = Player.where(player_id: params[:data][:player_id]).first
          player_ids = [(player.broadcast_id.present? ? "broadcast:#{player.broadcast_id}" : player.player_id)]
        end
      end
      player_ids.each do |player_id|
        VideoPlayerChannel.broadcast_to(player_id, message)
      end
    end
  end
end
