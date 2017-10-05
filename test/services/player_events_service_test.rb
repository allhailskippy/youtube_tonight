require 'test_helper'

class PlayerEventsServiceTest < ActiveSupport::TestCase
  test 'gets events' do
    expected = [
      :registered, :unregistered, :registered_check, :play, :playing, :stop,
      :stopped, :pause, :paused, :unpause, :unpaused, :mute, :muted, :unmute,
      :unmuted, :set_time, :get_current_state, :current_state
    ]
    expected.each do |method|
      assert PlayerEvents.events.include?(method)
    end
    assert_equal expected.length, PlayerEvents.events.length
  end
end
