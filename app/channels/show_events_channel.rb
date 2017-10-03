class ShowEventsChannel < ApplicationCable::Channel
  def subscribed
    show = Show.find(params[:data][:show_id])
    stream_for show
  end
end
