require 'test_helper'
 
class PlayerTest < ActiveSupport::TestCase
  test 'model stamper' do
    stamp = create(:user)
    User.stamper = stamp
    player = create(:player)

    assert_equal stamp, player.creator 
    assert_equal stamp, player.updater
  end

  test "relationships" do
    user = create(:user)  
    player = create(:player, user: user)
    assert_equal user, player.user
  end
end
