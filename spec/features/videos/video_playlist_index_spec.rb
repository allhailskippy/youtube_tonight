require 'rails_helper'

shared_examples "the video playlist index page" do
  let(:playlist) { create(:playlist_with_videos, user: current_user, videocount: 3) }

  before do
    @page.load(playlist_id: playlist.id)
    wait_for_angular_requests_to_finish
  end

  it 'gets the index' do
    expect(@page.rows.length).to eq(3)
    playlist.videos.each do |video|
      row = @page.find_row(video)
      expect(row.thumbnail['src']).to eq(video.api_thumbnail_default_url)
      expect(row.title.text).to eq("Title: #{video.title}")
      expect(row.channel.text).to eq("Channel: #{video.api_channel_title}")
    end
    expect(@page.reimport_videos['ng-click']).to eq("reimportVideos()")
  end

  it 'has the back button' do
    expect(@page.back['href']).to end_with('/#/playlists')
  end

  it 'goes back' do
    @page.back.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with("/#/playlists")
  end

  it_should_behave_like "user_info" do
    let(:user_info) { @page.user_info }
  end

  it_should_behave_like "playlist_info" do
    let(:playlist_info ) { @page.playlist_info }
  end

  it 'starts the preview' do
    row = @page.find_row(playlist.videos.first)
    row.preview_start.click
    wait_for_angular_requests_to_finish
    expect(row.preview_start['disabled']).to eq("disabled")
  end
end

shared_examples "duration" do
  let(:playlist) { create(:playlist, user: current_user) }
  let(:video1) { create(:video, parent: playlist, api_duration: 'PT44S') }
  let(:video2) { create(:video, parent: playlist, api_duration: 'PT45S') }
  let(:video3) { create(:video, parent: playlist, api_duration: 'PT1M29S') }
  let(:video4) { create(:video, parent: playlist, api_duration: 'PT1M30S') }
  let(:video5) { create(:video, parent: playlist, api_duration: 'PT2M29S') }
  let(:video6) { create(:video, parent: playlist, api_duration: 'PT2M30S') }
  let(:video7) { create(:video, parent: playlist, api_duration: 'PT1H29M05S') }
  let(:video8) { create(:video, parent: playlist, api_duration: 'PT1H30M15S') }
  let(:video9) { create(:video, parent: playlist, api_duration: 'PT2H29M20S') }
  let(:video10) { create(:video, parent: playlist, api_duration: 'PT2H30M30S') }
  let(:preload) { playlist; video1; video2; video3; video4; video5; video6; video7; video8; video9; video10 }

  before do
    @page.load(playlist_id: playlist.id)
    wait_for_angular_requests_to_finish
  end

  it 'has the correct durations' do
    row = @page.find_row(video1)
    expected = "Duration: a few seconds (44s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video2)
    expected = "Duration: a minute (45s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video3)
    expected = "Duration: a minute (1m29s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video4)
    expected = "Duration: 2 minutes (1m30s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video5)
    expected = "Duration: 2 minutes (2m29s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video6)
    expected = "Duration: 3 minutes (2m30s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video7)
    expected = "Duration: an hour (1h29m5s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video8)
    expected = "Duration: 2 hours (1h30m15s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video9)
    expected = "Duration: 2 hours (2h29m20s)"
    expect(row.duration.text).to eq(expected)

    row = @page.find_row(video10)
    expected = "Duration: 3 hours (2h30m30s)"
    expect(row.duration.text).to eq(expected)
  end
end

# Check when accessing the currently logged in user
describe 'Admin User: /#/playlists/:playlist_id/videos', js: true, type: :feature do
  let(:admin) { create_user(role_titles: [:admin]) }
  let(:current_user) { admin }
  let(:preload) { admin }

  before do
    preload if defined?(preload)
    sign_in(admin)
    @page = VideosPlaylistIndexPage.new
  end

  it_behaves_like "the video playlist index page"
  it_behaves_like "duration"

  it_should_behave_like "paginated" do
    let(:playlist) { create(:playlist_with_videos, user: admin, videocount: 100) }
    let(:page_pagination) { @page.pagination_top }
    let(:objects) { playlist.videos }
    let(:results_method) { :rows }
    let(:site_page) { @page }

    before do
      sign_in_admin
      @page.load(playlist_id: playlist.id)
      wait_for_angular_requests_to_finish
    end
  end
end

# Check when accessing a host user
describe 'Host User: /#/playlists/:playlist_id/videos', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:current_user) { host }
  let(:preload) { host }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = VideosPlaylistIndexPage.new
  end

  it_behaves_like "the video playlist index page"
  it_behaves_like "duration"

  it_should_behave_like "paginated" do
    let(:playlist) { create(:playlist_with_videos, user: host, videocount: 100) }
    let(:page_pagination) { @page.pagination_top }
    let(:objects) { playlist.videos }
    let(:results_method) { :rows }
    let(:site_page) { @page }

    before do
      sign_in(host)
      @page.load(playlist_id: playlist.id)
      wait_for_angular_requests_to_finish
    end
  end
end

# Check when accessing a non-logged in user
describe 'Not Logged In: /#/playlists/:playlist_id/videos', js: true, type: :feature do
  it_behaves_like "guest_access" do
    let(:loader) { VideosPlaylistIndexPage.new.load(playlist_id: 1) }
  end
end
