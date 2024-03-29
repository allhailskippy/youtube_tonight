WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name

  namespace :video_player do 
    PlayerEvents.events.each do |e|
      subscribe e, "video_player##{e}"
    end
  end

  namespace :playlist_events do
    Playlist.events.each do |e|
      subscribe e, "playlist_events##{e}"
    end
  end
end
