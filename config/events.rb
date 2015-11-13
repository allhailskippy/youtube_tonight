WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name

  namespace :video_player do 
     events = [
      :play, :playing,
      :stop, :stopped,
      :pause, :paused,
      :mute, :muted,
      :unmute, :unmuted
    ]
    events.each do |e|
      subscribe e, "video_player##{e}"
    end
  end
end
