require 'rails_helper'
require_relative '../shared/pagination'

# There are 2 ways to access this page;
# Either the user can be specified, or the currently logged in user is used
shared_examples "the index page" do
  subject { page }

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
      expect(expected).to end_with("/app#/videos/playlists/#{playlist.id}")
    end

    expect(@page.reimport_playlists['ng-click']).to eq("reimportPlaylists()")
  end

  it 'has the user info section' do
    ui = @page.user_info
    expect(ui.user_id.text).to eq(current_user.id.to_s)
    expect(ui.name.text).to eq(current_user.name)
    expect(ui.email.text).to eq(current_user.email)
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
        expect(page.current_url).to end_with("/app#/videos/playlists/#{playlist1.id}")
      end

      it 'goes for playlist2' do
        row = @page.find_row(playlist2)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/app#/videos/playlists/#{playlist2.id}")
      end
    end
  end
end

# Check when accessing the currently logged in user
describe 'Admin User: /app#/playlists/index', js: true, type: :feature do
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

  it_behaves_like "the index page"

  it 'does not have the back button' do
    expect{@page.back}.to raise_error(Capybara::ElementNotFound)
  end
end

# Check when accessing a different user than the one currently logged in
describe 'Admin User: /app#/playlists/:user_id/index', js: true, type: :feature do
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

  it_behaves_like "the index page"

  it 'has the back button' do
    expect(@page.back['href']).to end_with('/app#/users/index')
  end
end

describe 'Admin User: /app#/playlists/index pagination', js: true, type: :feature do
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

  it_should_behave_like "paginated" do
    let(:page_pagination) { @page.pagination }
    let(:objects) { playlists }
    let(:results_method) { :rows }
    let(:site_page) { @page }
  end
end

# Check when accessing the currently logged in user
describe 'Host User: /app#/playlists/index', js: true, type: :feature do
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

  it_behaves_like "the index page"

  it 'does not have the back button' do
    expect{@page.back}.to raise_error(Capybara::ElementNotFound)
  end
end

describe 'Host User: /app#/playlists/index pagination', js: true, type: :feature do
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

  it_should_behave_like "paginated" do
    let(:page_pagination) { @page.pagination }
    let(:objects) { playlists }
    let(:results_method) { :rows }
    let(:site_page) { @page }
  end

  it 'does not have the back button' do
    expect{@page.back}.to raise_error(Capybara::ElementNotFound)
  end
end

# Check when accessing with the current user in the url
describe 'Host User: /app#/playlists/:user_id/index', js: true, type: :feature do
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

  it_behaves_like "the index page"

  it 'does not have the back button' do
    expect{@page.back}.to raise_error(Capybara::ElementNotFound)
  end
end

describe 'Host User: /app#/playlists/:user_id/index pagination', js: true, type: :feature do
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

  it_should_behave_like "paginated" do
    let(:page_pagination) { @page.pagination }
    let(:objects) { playlists }
    let(:results_method) { :rows }
    let(:site_page) { @page }
  end

  it 'does not have the back button' do
    expect{@page.back}.to raise_error(Capybara::ElementNotFound)
  end
end

describe 'Not Logged In: /app#/playlists/index', js: true, type: :feature do
  subject { page }

  before do
    preload if defined?(preload)
  end

  it 'goes to sign in' do
    @page = PlaylistsIndexPage.new
    @page.load
    wait_for_angular_requests_to_finish

    expect(page.current_url).to include("/users/sign_in")
  end
end

describe 'Not Logged In: /app#/playlists/:user_id/index', js: true, type: :feature do
  subject { page }

  before do
    preload if defined?(preload)
  end

  it 'goes to sign in' do
    @page = PlaylistsUserIndexPage.new
    @page.load(user_id: 1)
    wait_for_angular_requests_to_finish

    expect(page.current_url).to include("/users/sign_in")
  end
end
