require 'rails_helper'

describe '/app#/users/index', js: true do
  subject { page }

  let(:user1) do
    Authorization.current_user = User.find(SYSTEM_ADMIN_ID)
    u = without_access_control {  create(:user, name: 'User 1') }
    return User.find(u.id)
  end
  let(:preload) { user1 }

  before do
    preload if defined?(preload)
    sign_in(user1)
    visit '/app#/users/index'
    wait_for_angular_requests_to_finish
  end

  it 'gets the index' do
    # TODO: Actually test something
  end
end
