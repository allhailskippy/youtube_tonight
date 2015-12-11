class PlayerEvents
   def self.events
     [
      :registered, :unregistered,
      :registered_check,
      :play, :playing,
      :stop, :stopped,
      :pause, :paused,
      :unpause, :unpaused,
      :mute, :muted,
      :unmute, :unmuted,
      :set_time,
      :get_current_state, :current_state
    ]
  end
end
