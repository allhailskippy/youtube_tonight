class PlayerEvents
   def self.events
     [
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
