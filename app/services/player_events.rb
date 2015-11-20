class PlayerEvents
   def self.events
     [
      :registered, :unregistered,
      :registered_check,
      :play, :playing,
      :stop, :stopped,
      :pause, :paused,
      :mute, :muted,
      :unmute, :unmuted,
      :currently_playing,
      :set_time
    ]
  end
end
