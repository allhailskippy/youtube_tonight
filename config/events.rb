WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name

  namespace :video_player do 
    subscribe :load, 'video_player#load'
    subscribe :ready, 'video_player#ready'
    subscribe :play, 'video_player#play'
    subscribe :pause, 'video_player#pause'
    subscribe :stop, 'video_player#stop'
    subscribe :mute, 'video_player#mute'
    subscribe :unmute, 'video_player#unmute'
    subscribe :set_volume, 'video_player#set_volume'
  end
end
