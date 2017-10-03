class PlaylistEventsChannel < ApplicationCable::Channel
  def subscribed
    user = User.find(params[:data][:user_id])
    stream_for user
  end
end
