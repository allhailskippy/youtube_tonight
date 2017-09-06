require 'rails_helper'

describe '/app#/users/index', js: true, type: :feature do
  subject { page }

  let(:admin) { u = without_access_control { create(:user, name: 'User 1') }; User.find(u.id) }
  let(:host1) { u = without_access_control { create(:user, name: 'Host 1', role_titles: [:host]) }; User.find(u.id) }
  let(:host2) { u = without_access_control { create(:user, name: 'Host 2', role_titles: [:host], requires_auth: true) }; User.find(u.id) }
  let(:host3) { u = without_access_control { create(:user, name: 'Host 3', role_titles: [:host, :admin]) }; User.find(u.id) }
  let(:preload) do
    admin
    host1
    host2
    host3
  end

  before do
    preload if defined?(preload)
    sign_in(admin)
    @users_index_page = UsersIndexPage.new
    @users_index_page.load
    wait_for_angular_requests_to_finish
  end

  it 'gets the index' do
    expect(@users_index_page.user_rows.length).to eq(4)

    @users_index_page.user_rows.each do |ur|
      user = User.find(ur.user_id.text.to_i)

      expect(ur.profile_image['src']).to eq(user.profile_image)
      expect(ur.name.text).to eq(user.name)
      expect(ur.email.text).to eq(user.email)

      expected = user.role_titles.map{|r| r.capitalize }.join(', ')
      expect(ur.roles.text).to eq(expected)
    end
  end

  it 'does not show the system user' do
    ids = find_all('#users tbody td.user-id').collect(&:text)
    found = ids.include?(SYSTEM_ADMIN_ID.to_s)
    expect(found).to be(false)
  end

  it 'has all the right buttons' do
    # Admin
    row = @users_index_page.find_row(admin)
    expect { row.sec_actions.deauthorize }.to raise_error(Capybara::ElementNotFound)
    expect { row.sec_actions.authorize }.to raise_error(Capybara::ElementNotFound)
    expect { row.sec_actions.edit }.to raise_error(Capybara::ElementNotFound)

    # Host 1
    row = @users_index_page.find_row(host1)
    expected = row.sec_actions.deauthorize['ng-click']
    expect(expected).to eq('deAuthorize(user)')
    expect { row.sec_actions.authorize }.to raise_error(Capybara::ElementNotFound)
    expected = row.sec_actions.edit['ng-click']
    expect(expected).to eq('edit(user)')
    expected = row.sec_actions.videos['href']
    expect(expected).to end_with("/app#/playlists/#{host1.id}/index")

    # Host 2
    row = @users_index_page.find_row(host2)
    expect { row.sec_actions.deauthorize }.to raise_error(Capybara::ElementNotFound)
    expected = row.sec_actions.authorize['ng-click']
    expect(expected).to eq('authorize(user)')
    expected = row.sec_actions.edit['ng-click']
    expect(expected).to eq('edit(user)')
    expected = row.sec_actions.videos['href']
    expect(expected).to end_with("/app#/playlists/#{host2.id}/index")

    # Host 3
    row = @users_index_page.find_row(host3)
    expect { row.sec_actions.deauthorize }.to raise_error(Capybara::ElementNotFound)
    expect { row.sec_actions.authorize }.to raise_error(Capybara::ElementNotFound)
    expected = row.sec_actions.edit['ng-click']
    expect(expected).to eq('edit(user)')
    expected = row.sec_actions.videos['href']
    expect(expected).to end_with("/app#/playlists/#{host3.id}/index")
  end
end
