require 'test_helper'
 
class ShowUserTest < ActiveSupport::TestCase
  test "relationships" do
    user = create(:user)  
    show_user = create(:show_user, user: user)
    assert_equal user, show_user.user

    show = create(:show)
    show_user2 = create(:show_user, show: show)
    assert_equal show, show_user2.show
  end
end
