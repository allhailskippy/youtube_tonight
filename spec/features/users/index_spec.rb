require 'rails_helper'

describe 'Admin User: /app#/users/index', js: true, type: :feature do
  subject { page }

  let(:admin) { create_user() }
  let(:host1) { create_user(name: 'Host 1', role_titles: [:host]) }
  let(:host2) { create_user(name: 'Host 2', role_titles: [], requires_auth: true) }
  let(:host3) { create_user(name: 'Host 3', role_titles: [:host, :admin]) }
  let(:preload) { admin; host1; host2; host3 }

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

  describe 'actions' do
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

    describe 'authorization' do
      it 'toggles host1' do
        # Deauthorize
        row = @users_index_page.find_row(host1)
        accept_confirm("Are you sure you want to de-authorize this user?\nThey will no longer be allowed to sign in.") do
          row.sec_actions.deauthorize.click()
        end
        wait_for_angular_requests_to_finish

        # Verify
        host1.reload
        expect(host1.role_titles).to eq([])
        expect(host1.requires_auth).to eq(true)
        expected = row.sec_actions.authorize['ng-click']
        expect(expected).to eq('authorize(user)')

        # Reauthorize
        row.sec_actions.authorize.click()
        wait_for_angular_requests_to_finish

        # Verify
        host1.reload
        expect(host1.role_titles).to eq([:host])
        expect(host1.requires_auth).to eq(false)
        expected = row.sec_actions.deauthorize['ng-click']
        expect(expected).to eq('deAuthorize(user)')
      end

      it 'aborts toggle requrest for host1' do
        # Deauthorize
        row = @users_index_page.find_row(host1)
        dismiss_confirm("Are you sure you want to de-authorize this user?\nThey will no longer be allowed to sign in.") do
          row.sec_actions.deauthorize.click()
        end

        # Verify
        host1.reload
        expect(host1.role_titles).to eq([:host])
        expect(host1.requires_auth).to eq(false)
        expected = row.sec_actions.deauthorize['ng-click']
        expect(expected).to eq('deAuthorize(user)')
      end

      it 'toggles host2' do
        # Authorize
        row = @users_index_page.find_row(host2)
        row.sec_actions.authorize.click()
        wait_for_angular_requests_to_finish

        # Verify
        host2.reload
        expect(host2.role_titles).to eq([:host])
        expect(host2.requires_auth).to eq(false)
        expected = row.sec_actions.deauthorize['ng-click']
        expect(expected).to eq('deAuthorize(user)')

        # De-authorize
        accept_confirm("Are you sure you want to de-authorize this user?\nThey will no longer be allowed to sign in.") do
          row.sec_actions.deauthorize.click()
        end
        wait_for_angular_requests_to_finish

        # Verify
        host2.reload
        expect(host2.role_titles).to eq([])
        expect(host2.requires_auth).to eq(true)
        expected = row.sec_actions.authorize['ng-click']
        expect(expected).to eq('authorize(user)')
      end
    end

    describe 'goes to edit' do
      it 'for host1' do
        row = @users_index_page.find_row(host1)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/app#/users/#{host1.id}/edit")
      end

      it 'for host2' do
        row = @users_index_page.find_row(host2)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/app#/users/#{host2.id}/edit")
      end

      it 'for host3' do
        row = @users_index_page.find_row(host3)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/app#/users/#{host3.id}/edit")
      end
    end

    describe 'videos' do
      it 'goes for admin' do
        row = @users_index_page.find_row(admin)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/app#/playlists/#{admin.id}/index")
      end

      it 'goes for host1' do
        row = @users_index_page.find_row(host1)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/app#/playlists/#{host1.id}/index")
      end

      it 'goes for host2' do
        row = @users_index_page.find_row(host2)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/app#/playlists/#{host2.id}/index")
      end

      it 'goes for host3' do
        row = @users_index_page.find_row(host3)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/app#/playlists/#{host3.id}/index")
      end
    end
  end
end

describe 'Host User: /app#/users/index', js: true, type: :feature do
  subject { page }

  let(:host) { u = without_access_control { create(:user, role_titles: [:host]) }; User.find(u.id) }
  let(:preload) { host }

  before do
    preload if defined?(preload)
    sign_in(host)
  end

  it 'does not get the index' do
    @users_index_page = UsersIndexPage.new
    @users_index_page.load
    sleep 2
    expected = find('body').text
    expect(expected).to eq('Unauthorized')
    expect(page.current_url).to end_with("/unauthorized")
  end
end

describe 'Not Logged In: /app#/users/index', js: true, type: :feature do
  subject { page }

  before do
    preload if defined?(preload)
  end

  it 'goes to sign in' do
    @users_index_page = UsersIndexPage.new
    @users_index_page.load
    wait_for_angular_requests_to_finish

    expect(page.current_url).to include("/users/sign_in")
  end
end
