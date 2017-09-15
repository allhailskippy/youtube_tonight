require 'rails_helper'

# There are 2 ways to access this page;
# Either the user can be specified, or the currently logged in user is used
shared_examples "the index page" do
  it 'gets the index' do
    expect(@page.rows.length).to eq(2)

    [playlist1, playlist2].each do |playlist|
      row = @page.find_row(playlist)

      expect(row.thumbnail['src']).to eq(playlist.api_thumbnail_default_url)
      expect(row.title.text).to eq(playlist.api_title)
      expect(row.description.text).to eq(playlist.api_description)
      expect(row.video_count.text).to eq(playlist.video_count.to_s)

      expected = row.sec_actions.refresh_videos['ng-click']
      expect(expected).to eq("reimportVideos(playlist)")

      expected = row.sec_actions.videos['href']
      if userPath
        expect(expected).to end_with("/#/users/#{playlist.user_id}/playlists/#{playlist.id}/videos")
      else
        expect(expected).to end_with("/#/playlists/#{playlist.id}/videos")
      end
    end

    expect(@page.reimport_playlists['ng-click']).to eq("reimportPlaylists()")
  end

  it_should_behave_like "user_info" do
    let(:user_info) { @page.user_info }
  end

  it 'searches correctly' do
    @page.search.set('Custom Title')
    wait_for_angular_requests_to_finish

    expect(@page.rows.length).to eq(1)

    row = @page.find_row(playlist1)
    expect(row.title.text).to eq(playlist1.api_title)

    expect(@page.find_row(playlist2)).to be_nil
  end

  describe 'actions' do
    it 'reimports video' do
      skip "TODO: With TID-8"
    end

    describe 'videos' do
      it 'goes for playlist1' do
        row = @page.find_row(playlist1)
        row.sec_actions.videos.click()
        if userPath
          expect(page.current_url).to end_with("/#/users/#{playlist1.user_id}/playlists/#{playlist1.id}/videos")
        else
          expect(page.current_url).to end_with("/#/playlists/#{playlist1.id}/videos")
        end
      end

      it 'goes for playlist2' do
        row = @page.find_row(playlist2)
        row.sec_actions.videos.click()
        if userPath
          expect(page.current_url).to end_with("/#/users/#{playlist2.user_id}/playlists/#{playlist2.id}/videos")
        else
          expect(page.current_url).to end_with("/#/playlists/#{playlist2.id}/videos")
        end
      end
    end
  end
end

# Check when accessing the currently logged in user
describe 'Admin User: /#/playlists/index', js: true, type: :feature do
  let(:admin) { create_user(role_titles: [:admin]) }
  let(:playlist1) { create(:playlist_with_videos, api_title: 'Custom Title', user: admin) }
  let(:playlist2) { create(:playlist_with_videos, api_title: 'Not Searched', user: admin, videocount: 10) }
  let(:playlist3) { create(:playlist_with_videos) }
  let(:current_user) { admin }
  let(:preload) { current_user; admin; playlist1; playlist2; playlist3 }

  before do
    preload if defined?(preload)
    sign_in(admin)
    @page = PlaylistsIndexPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'admin menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_behaves_like "the index page" do
    let(:current_user) { admin }
    let(:userPath) { false }
  end

  it 'does not have the back button' do
    using_wait_time(0) do
      expect{@page.back}.to raise_error(Capybara::ElementNotFound)
    end
  end
end

# Check when accessing a different user than the one currently logged in
describe 'Admin User: /#/playlists/:user_id/index', js: true, type: :feature do
  let(:admin) { create_user(role_titles: [:admin]) }
  let(:user) { create_user(role_titles: [:host]) }
  let(:playlist1) { create(:playlist_with_videos, api_title: 'Custom Title', user: user) }
  let(:playlist2) { create(:playlist_with_videos, api_title: 'Not Searched', user: user, videocount: 10) }
  let(:playlist3) { create(:playlist_with_videos, user: admin) }
  let(:current_user) { user }
  let(:preload) { current_user; user; admin; playlist1; playlist2; playlist3 }

  before do
    preload if defined?(preload)
    sign_in_admin
    @page = PlaylistsUserIndexPage.new
    @page.load(user_id: user.id)
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'admin menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_behaves_like "the index page" do
    let(:current_user) { user }
    let(:userPath) { true }
  end

  it 'has the back button' do
    expect(@page.back['href']).to end_with('/#/users')
  end
end

describe 'Admin User: /#/playlists pagination', js: true, type: :feature do
  let(:admin) { create_user(role_titles: [:admin]) }
  let(:user) { create_user(role_titles: [:host]) }
  let(:playlists) do
    100.times.collect do |n|
      create(:playlist, api_title: "Title #{n + 1}", user: user)
    end
  end
  let(:current_user) { user }
  let(:preload) { current_user; user; admin; playlists }

  before do
    preload if defined?(preload)
    sign_in_admin
    @page = PlaylistsUserIndexPage.new
    @page.load(user_id: user.id)
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'admin menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_should_behave_like "paginated" do
    let(:page_pagination) { @page.pagination }
    let(:objects) { playlists }
    let(:results_method) { :rows }
    let(:site_page) { @page }
  end
end

# Check when accessing the currently logged in user
describe 'Host User: /#/playlists', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:playlist1) { create(:playlist_with_videos, api_title: 'Custom Title', user: host) }
  let(:playlist2) { create(:playlist_with_videos, api_title: 'Not Searched', user: host, videocount: 10) }
  let(:playlist3) { create(:playlist_with_videos) }
  let(:current_user) { host }
  let(:preload) { current_user; host; playlist1; playlist2; playlist3 }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = PlaylistsIndexPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'host menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_behaves_like "the index page" do
    let(:current_user) { host }
    let(:userPath) { false }
  end

  it 'does not have the back button' do
    using_wait_time(0) do
      expect{@page.back}.to raise_error(Capybara::ElementNotFound)
    end
  end
end

describe 'Host User: /#/playlists pagination', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:playlists) do
    100.times.collect do |n|
      create(:playlist, api_title: "Title #{n + 1}", user: host)
    end
  end
  let(:current_user) { host }
  let(:preload) { current_user; host; playlists }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = PlaylistsIndexPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'host menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_should_behave_like "paginated" do
    let(:page_pagination) { @page.pagination }
    let(:objects) { playlists }
    let(:results_method) { :rows }
    let(:site_page) { @page }
  end

  it 'does not have the back button' do
    using_wait_time(0) do
      expect{@page.back}.to raise_error(Capybara::ElementNotFound)
    end
  end
end

# Check when accessing with the current user in the url
describe 'Host User: /#/users/:user_id/playlists', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:playlist1) { create(:playlist_with_videos, api_title: 'Custom Title', user: host) }
  let(:playlist2) { create(:playlist_with_videos, api_title: 'Not Searched', user: host, videocount: 10) }
  let(:playlist3) { create(:playlist_with_videos) }
  let(:current_user) { host}
  let(:preload) { current_user; host; playlist1; playlist2; playlist3 }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = PlaylistsUserIndexPage.new
    @page.load(user_id: host.id)
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'host menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_behaves_like "the index page" do
    let(:current_user) { host }
    let(:userPath) { true }
  end

  it 'does not have the back button' do
    using_wait_time(0) do
      expect{@page.back}.to raise_error(Capybara::ElementNotFound)
    end
  end
end

describe 'Host User: /#/users/:user_id/playlists pagination', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:playlists) do
    100.times.collect do |n|
      create(:playlist, api_title: "Title #{n + 1}", user: host)
    end
  end
  let(:current_user) { host }
  let(:preload) { current_user; host; playlists }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = PlaylistsUserIndexPage.new
    @page.load(user_id: host.id)
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'host menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_should_behave_like "paginated" do
    let(:page_pagination) { @page.pagination }
    let(:objects) { playlists }
    let(:results_method) { :rows }
    let(:site_page) { @page }
  end

  it 'does not have the back button' do
    using_wait_time(0) do
      expect{@page.back}.to raise_error(Capybara::ElementNotFound)
    end
  end
end

describe 'Not Logged In: /#/playlists', js: true, type: :feature do
  before do
    @page = PlaylistsUserIndexPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'guest menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_behaves_like "guest_access"
end

describe 'Not Logged In: /#/users/:user_id/playlists', js: true, type: :feature do
  before do
    @page = PlaylistsUserIndexPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'guest menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Playlists' }
  end

  it_behaves_like "guest_access"
end
