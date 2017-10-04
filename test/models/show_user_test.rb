require 'test_helper'
 
class ShowUserTest < ActiveSupport::TestCase
  test "relationships" do
    user = create(:user)  
    show_user = create(:show_user, user: user)
    assert_equal user, show_user.user
  end
end
