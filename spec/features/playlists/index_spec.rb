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

  it 'reimports all playlists' do
    stub_videos

    # Queues up the video import requests
    expect {
      @page.reimport_playlists.click
      wait_for_angular_requests_to_finish
    }.to change(VideoImportWorker.jobs, :size).by(5)

    current_user.playlists.reload

    expect(current_user.playlists.length).to eq(5)
    ["def5678", "ghi91011", "jkl121314", "plr1", "plr2"].each do |list|
      expect(current_user.playlists.collect(&:api_playlist_id)).to include(list)
    end

    # Executes the video import requests
    VideoImportWorker.drain

    # Videos should be the ones from the stub
    expected = ["a123", "a124", "b234", "c123ghi91011", "c123jkl121314", "c123plr1", "c123plr2"]
    expect(current_user.playlists.collect{|p| p.videos.collect(&:api_video_id) }.flatten).to eq(expected)
  end

  describe 'actions' do
    it 'reimports videos for playlist' do
      stub_videos_for_playlist(playlist1.api_playlist_id)

      row = @page.find_row(playlist1)
      expect(row.sec_actions.refresh_videos['disabled']).to be_blank

      expect {
        row.sec_actions.refresh_videos.click
        wait_for_angular_requests_to_finish
      }.to change(VideoImportWorker.jobs, :size).by(1)

      expect {
        # Workder should remove the existing 5 videos and
        # replace it with 1 video. Therefore change of -4
        VideoImportWorker.drain
      }.to change(playlist1.videos, :count).by(-4)

      row = @page.find_row(playlist1)
      expect(row.sec_actions.refresh_videos['disabled']).to be_blank
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

describe 'Admin User (requires auth): /#/playlists/index', js: true, type: :feature do
  let(:current_user) { create_user(role_titles: [:admin], requires_auth: true) }
  before do
    sign_in(current_user)
    @page = PlaylistsIndexPage.new
    @page.load
    sleep 1
    wait_for_angular_requests_to_finish
  end

  it_behaves_like "requires_auth"
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

describe 'Admin User (requires auth): /#/playlists/:user_id/index', js: true, type: :feature do
  let(:current_user) { create_user(role_titles: [:admin], requires_auth: true) }
  before do
    sign_in(current_user)
    @page = PlaylistsUserIndexPage.new
    @page.load(user: current_user)
    sleep 1
    wait_for_angular_requests_to_finish
  end

  it_behaves_like "requires_auth"
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

describe 'Host User (requires auth): /#/playlists/index', js: true, type: :feature do
  let(:current_user) { create_user(role_titles: [:host], requires_auth: true) }
  before do
    sign_in(current_user)
    @page = PlaylistsIndexPage.new
    @page.load
    sleep 1
    wait_for_angular_requests_to_finish
  end

  it_behaves_like "requires_auth"
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

describe 'Host User (requires auth): /#/playlists/:user_id/index', js: true, type: :feature do
  let(:current_user) { create_user(role_titles: [:host], requires_auth: true) }
  before do
    sign_in(current_user)
    @page = PlaylistsUserIndexPage.new
    @page.load(user: current_user)
    sleep 1
    wait_for_angular_requests_to_finish
  end

  it_behaves_like "requires_auth"
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
