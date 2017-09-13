require 'rails_helper'

shared_examples "the index page" do
  let(:show) { create(:show, users: [current_user]) }
  let(:video1) { create(:video, parent: show, start_time: 10, end_time: 15) }
  let(:video2) { create(:video, parent: show) }
  let(:video3) { create(:video, parent: show) }
  let(:preload) { show; video1; video2; video3; show.reload }

  before do
    @page.load(show_id: show.id)
    wait_for_angular_requests_to_finish
  end

  it 'gets the index' do
    expect(@page.rows.length).to eq(3)
    show.videos.each do |video|
      row = @page.find_row(video)
      expect(row.thumbnail['src']).to eq(video.api_thumbnail_default_url)
      expect(row.title.text).to eq("Title: #{video.title}")
      expect(row.channel.text).to eq("Channel: #{video.api_channel_title}")
      if(video.start_time)
        expect(row.start_at.text).to eq("Start At: #{video.start_time}")
      end
      if(video.end_time)
        expect(row.end_at.text).to eq("End At: #{video.end_time}")
      end
    end
  end

  it 'has the add video button' do
    expect(@page.add_video['ng-click']).to eq('addVideo()')
  end

  it 'has the back button' do
    expect(@page.back['href']).to end_with('/#/shows')
  end

  it 'goes back' do
    @page.back.click
    wait_for_angular_requests_to_finish
    expect(page.current_url).to end_with("/#/shows")
  end

  context 'add new video' do
    it 'goes adds a new video to the show' do
      response = [{
        "video_id": "1234abcd",
        "published_at": "2017-04-01T11:07:36.000+00:00",
        "channel_id": "channelid",
        "channel_title": "channel title",
        "description": "this is a description",
        "thumbnail_default_url": "https://i.ytimg.com/vi/furTlhb-990/default.jpg",
        "thumbnail_medium_url": "https://i.ytimg.com/vi/furTlhb-990/mqdefault.jpg",
        "thumbnail_high_url": "https://i.ytimg.com/vi/furTlhb-990/hqdefault.jpg",
        "title": "fake title",
        "link": "https://www.youtube.com/v/1234abcd",
        "duration": "PT18M13S",
        "duration_seconds": 1093.0
      }]
      allow(YoutubeApi).to receive(:get_video_info).and_return(response)

      @page.add_video.click
      sleep 1
      expect(@page.video_form).to_not be_nil

      @page.video_form.search.set('search text')
      blur
      sleep 1
      wait_for_angular_requests_to_finish

      expect(@page.search_results.length).to eq(1)
      
      row = @page.search_results.first
      expect(row.select_result['ng-click']).to eq('selectResult(video)')
      expect(row.thumbnail['src']).to eq('https://i.ytimg.com/vi/furTlhb-990/default.jpg')
      expect(row.preview_start['ng-click']).to eq('play()')
      expect(row.title.text).to eq('Title: fake title')
      expect(row.channel.text).to eq('Channel: channel title')
      expect(row.duration.text).to eq('Duration: 18 minutes (18m13s)') 
    end
  end
end

shared_examples "duration" do
  let(:show) { create(:show, users: [current_user]) }
  let(:video1) { create(:video, parent: show, api_duration: 'PT44S') }
  let(:video2) { create(:video, parent: show, api_duration: 'PT45S') }
  let(:video3) { create(:video, parent: show, api_duration: 'PT1M29S') }
  let(:video4) { create(:video, parent: show, api_duration: 'PT1M30S') }
  let(:video5) { create(:video, parent: show, api_duration: 'PT2M29S') }
  let(:video6) { create(:video, parent: show, api_duration: 'PT2M30S') }
  let(:video7) { create(:video, parent: show, api_duration: 'PT1H29M05S') }
  let(:video8) { create(:video, parent: show, api_duration: 'PT1H30M15S') }
  let(:video9) { create(:video, parent: show, api_duration: 'PT2H29M20S') }
  let(:video10) { create(:video, parent: show, api_duration: 'PT2H30M30S') }
  let(:preload) { show; video1; video2; video3; video4; video5; video6; video7; video8; video9; video10 }

  before do
    @page.load(show_id: show.id)
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
describe 'Admin User: /#/shows/:show_id/videos', js: true, type: :feature do
  let(:admin) { create_user(role_titles: [:admin]) }
  let(:current_user) { admin }
  let(:preload) { admin }

  before do
    preload if defined?(preload)
    sign_in(admin)
    @page = VideosShowsIndexPage.new
  end

  it_behaves_like "the index page"
  it_behaves_like "duration"
end

# Check when accessing a host user
describe 'Host User: /#/shows/:show_id/videos', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:current_user) { host }
  let(:preload) { host }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = VideosShowsIndexPage.new
  end

  it_behaves_like "the index page"
  it_behaves_like "duration"
end

# Check when accessing a non-logged in user
describe 'Not Logged In: /#/shows/:show_id/videos', js: true, type: :feature do
  it_behaves_like "guest_access" do
    let(:loader) { VideosShowsIndexPage.new.load(show_id: 1) }
  end
end
