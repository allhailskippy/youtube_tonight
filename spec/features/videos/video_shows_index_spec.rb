require 'rails_helper'

def stub_search_results(amount = 1)
  response_options = [{
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
  },{
    "video_id": "2222abcd",
    "published_at": "2017-04-02T12:00:37.000+00:00",
    "channel_id": "channelid2",
    "channel_title": "different channel title",
    "description": "this is also a description",
    "thumbnail_default_url": "https://i.ytimg.com/vi/furTlhb-990/default.jpg",
    "thumbnail_medium_url": "https://i.ytimg.com/vi/furTlhb-990/mqdefault.jpg",
    "thumbnail_high_url": "https://i.ytimg.com/vi/furTlhb-990/hqdefault.jpg",
    "title": "second title",
    "link": "https://www.youtube.com/v/1234abcd",
    "duration": "PT1M13S",
    "duration_seconds": 73.0
  }]
  response = response_options[0, amount]
  allow(YoutubeApi).to receive(:get_video_info).and_return(response)
end

shared_examples "the video show index page" do
  context 'index page actions' do
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

      # Has the launch broadcast button
      expect(@page.launch_broadcast['ng-click']).to eq('launchBroadcastPlayer()')
      new_window = window_opened_by { @page.launch_broadcast.click() }
      expect(new_window).to_not be_blank
      new_window.close
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
  end

  context 'add new video' do
    let(:show) { create(:show, users: [current_user]) }
    let(:video1) { create(:video, parent: show, start_time: 10, end_time: 15) }
    let(:video2) { create(:video, parent: show) }
    let(:video3) { create(:video, parent: show) }
    let(:preload) { show; video1; video2; video3; show.reload }

    before do
      @page.load(show_id: show.id)
      wait_for_angular_requests_to_finish
    end

    it 'goes adds a new video to the show' do
      stub_search_results()

      @page.add_video.click
      sleep 1
      expect(@page.video_form).to_not be_nil

      @page.video_form.search.set('search text')
      blur
      sleep 1
      wait_for_angular_requests_to_finish

      expect(@page.search_results.length).to eq(1)

      # Verify search results
      row = @page.search_results.first
      expect(row.select_result['ng-click']).to eq('selectResult(video)')
      expect(row.thumbnail['src']).to eq('https://i.ytimg.com/vi/furTlhb-990/default.jpg')
      expect(row.preview_start['ng-click']).to eq('play()')
      expect(row.title.text).to eq('Title: fake title')
      expect(row.channel.text).to eq('Channel: channel title')
      expect(row.duration.text).to eq('Duration: 18 minutes (18m13s)')
      expect(row.select_result['ng-click']).to eq('selectResult(video)')

      # Select video
      row.select_result.click

      # Verify that the video got selected
      row = @page.selected_video
      expect(row.clear['ng-click']).to eq('selectResult()')
      expect(row.thumbnail['src']).to eq('https://i.ytimg.com/vi/furTlhb-990/default.jpg')
      expect(row.preview_start['ng-click']).to eq('play()')
      expect(row.title.text).to eq('Title: fake title')
      expect(row.channel.text).to eq('Channel: channel title')
      expect(row.duration.text).to eq('Duration: 18 minutes (18m13s)')

      # Set values
      @page.video_form.title.set('changed title')
      @page.video_form.start_at.set('5')
      @page.video_form.end_at.set('30')

      # Verify values are changes
      expect(row.title.text).to eq('Title: changed title')
      expect(row.start_at.text).to eq('Start At: 5')
      expect(row.end_at.text).to eq('End At: 30')

      expect(row.add_to_queue["ng-click"]).to eq('save()')
      row.add_to_queue.click()
      wait_for_angular_requests_to_finish

      # Verify the video got added
      expect(@page.rows.length).to eq(4)

      row = @page.rows.last
      expect(row.thumbnail['src']).to eq('https://i.ytimg.com/vi/furTlhb-990/default.jpg')
      expect(row.preview_start['ng-click']).to eq('play()')
      expect(row.title.text).to eq('Title: changed title')
      expect(row.channel.text).to eq('Channel: channel title')
      expect(row.duration.text).to eq('Duration: 18 minutes (18m13s)')
      expect(row.start_at.text).to eq('Start At: 5')
      expect(row.end_at.text).to eq('End At: 30')
    end

    it 'cannot add to queue until a video has been selected' do
      stub_search_results()

      @page.add_video.click
      sleep 1

      @page.video_form.search.set('search text')
      blur
      sleep 1
      wait_for_angular_requests_to_finish

      # Should start disabled
      expect(@page.selected_video.add_to_queue["disabled"]).to be_truthy

      # Verify search results
      row = @page.search_results.first
      row.select_result.click

      # Should end not-disabled
      expect(@page.selected_video.add_to_queue["disabled"]).to be_blank
    end

    it 'can clear a selected video' do
      stub_search_results()

      @page.add_video.click
      sleep 1
      expect(@page.video_form).to_not be_nil

      @page.video_form.search.set('search text')
      blur
      sleep 1
      wait_for_angular_requests_to_finish

      expect(@page.search_results.length).to eq(1)

      row = @page.search_results.first
      row.select_result.click

      # Verify that the video got selected
      row = @page.selected_video
      row.clear.click()

      using_wait_time(0) do
        expect { @page.video_form.title }.to raise_error(Capybara::ElementNotFound)
        expect { @page.video_form.start_at }.to raise_error(Capybara::ElementNotFound)
        expect { @page.video_form.end_at }.to raise_error(Capybara::ElementNotFound)
        expect{row.thumbnail}.to  raise_error(Capybara::ElementNotFound)
        expect{row.preview_start}.to raise_error(Capybara::ElementNotFound)
        expect{row.title}.to raise_error(Capybara::ElementNotFound)
        expect{row.channel}.to raise_error(Capybara::ElementNotFound)
        expect{row.duration}.to raise_error(Capybara::ElementNotFound)
      end
    end

    it 'can cancel adding a video' do
      expect(@page.rows.length).to eq(3)

      @page.add_video.click
      sleep 1
      expect(@page.video_form).to_not be_nil

      expect(@page.selected_video.cancel['ng-click']).to eq('cancel()')
      @page.selected_video.cancel.click
      wait_for_angular_requests_to_finish

      expect(@page.rows.length).to eq(3)
    end

    it 'disables the select button for the currently selected video' do
      stub_search_results(2)

      @page.add_video.click
      sleep 1
      expect(@page.video_form).to_not be_nil

      @page.video_form.search.set('search text')
      blur
      sleep 1
      wait_for_angular_requests_to_finish

      expect(@page.search_results.length).to eq(2)

      row = @page.search_results.first
      row.select_result.click

      # Verify select button is disabled
      expect(row.select_result['disabled']).to be_truthy

      # Expect other results to still be enabled
      row = @page.search_results.last
      expect(row.select_result['disabled']).to be_blank
    end

    it 'can select a different video' do
      stub_search_results(2)

      @page.add_video.click
      sleep 1
      expect(@page.video_form).to_not be_nil

      @page.video_form.search.set('search text')
      blur
      sleep 1
      wait_for_angular_requests_to_finish

      expect(@page.search_results.length).to eq(2)

      row = @page.search_results.first
      row.select_result.click

      row = @page.selected_video
      expect(row.title.text).to eq('Title: fake title')

      row = @page.search_results.last
      row.select_result.click

      row = @page.selected_video
      expect(row.title.text).to eq('Title: second title')

      # select buttons are set correctly
      row = @page.search_results.first
      expect(row.select_result['disabled']).to be_blank
      row = @page.search_results.last
      expect(row.select_result['disabled']).to be_truthy
    end

    it 'can delete a video' do
      expect(@page.rows.length).to eq(3)

      row = @page.find_row(video1)
      expect(row.delete['ng-click']).to eq('destroy(video)')

      accept_confirm("Are you sure you want to delete this video from the queue?\nThis cannot be undone.") do
        row.delete.click
      end
      wait_for_angular_requests_to_finish

      expect(@page.rows.length).to eq(2)
    end

    it 'cancels deleting a video' do
      expect(@page.rows.length).to eq(3)

      row = @page.find_row(video1)
      expect(row.delete['ng-click']).to eq('destroy(video)')

      dismiss_confirm("Are you sure you want to delete this video from the queue?\nThis cannot be undone.") do
        row.delete.click
      end

      expect(@page.rows.length).to eq(3)
    end
  end

  context 'edit video' do
    let(:show) { create(:show, users: [current_user]) }
    let(:video1) { create(:video, parent: show, title: 'Video Title', start_time: 10, end_time: 15) }
    let(:preload) { show; video1 }

    before do
      @page.load(show_id: show.id)
      wait_for_angular_requests_to_finish
    end

    it 'can edit a video' do
      row = @page.find_row(video1)
      expect(row.edit['ng-click']).to eq('editVideo(video)')
      row.edit.click()
      sleep 1


      expect(@page.video_form).to_not be_nil
      row = @page.selected_video
      expect(row.title.text).to eq("Title: #{video1.title}")
      expect(row.start_at.text).to eq("Start At: #{video1.start_time}")
      expect(row.end_at.text).to eq("End At: #{video1.end_time}")

      @page.video_form.title.set('edited title')
      @page.video_form.start_at.set('')
      @page.video_form.end_at.set('')

      expect(row.update['ng-click']).to eq('update()')
      row.update.click()
      sleep 1
      wait_for_angular_requests_to_finish

      row = @page.find_row(video1)
      expect(row.title.text).to eq("Title: edited title")
      using_wait_time(0) do
        expect { row.start_at }.to raise_error(Capybara::ElementNotFound)
        expect { row.end_at }.to raise_error(Capybara::ElementNotFound)
      end
    end

    it 'cancels edit' do
      row = @page.find_row(video1)
      expect(row.edit['ng-click']).to eq('editVideo(video)')
      row.edit.click()
      sleep 1

      expect(@page.video_form).to_not be_nil
      row = @page.selected_video
      expect(row.title.text).to eq("Title: #{video1.title}")
      expect(row.start_at.text).to eq("Start At: #{video1.start_time}")
      expect(row.end_at.text).to eq("End At: #{video1.end_time}")

      @page.video_form.title.set('edited title')
      @page.video_form.start_at.set('')
      @page.video_form.end_at.set('')

      expect(row.cancel['ng-click']).to eq('cancel()')
      row.cancel.click
      wait_for_angular_requests_to_finish

      row = @page.find_row(video1)
      expect(row.title.text).to eq("Title: Video Title")
      expect(row.start_at.text).to eq("Start At: 10")
      expect(row.end_at.text).to eq("End At: 15")
    end
  end

  context 'show has no videos' do
    let(:show) { create(:show, users: [current_user]) }
    let(:preload) { show }

    before do
      @page.load(show_id: show.id)
      wait_for_angular_requests_to_finish
    end

    it 'should show the form to start' do
      stub_search_results()

      expect(@page.video_form).to_not be_nil

      @page.video_form.search.set('search text')
      blur
      sleep 1
      wait_for_angular_requests_to_finish

      @page.search_results.first.select_result.click
      @page.video_form.title.set('changed title')
      @page.video_form.start_at.set('5')
      @page.video_form.end_at.set('30')
      @page.selected_video.add_to_queue.click()
      wait_for_angular_requests_to_finish

      # Only one video should be shown now
      expect(@page.rows.length).to eq(1)

      row = @page.rows.first
      expect(row.thumbnail['src']).to eq('https://i.ytimg.com/vi/furTlhb-990/default.jpg')
      expect(row.preview_start['ng-click']).to eq('play()')
      expect(row.title.text).to eq('Title: changed title')
      expect(row.channel.text).to eq('Channel: channel title')
      expect(row.duration.text).to eq('Duration: 18 minutes (18m13s)')
      expect(row.start_at.text).to eq('Start At: 5')
      expect(row.end_at.text).to eq('End At: 30')
    end

    it 'disables the cancel button until a video is added' do
      stub_search_results()

      expect(@page.selected_video.cancel['disabled']).to be_truthy

      @page.video_form.search.set('search text')
      blur
      sleep 1
      wait_for_angular_requests_to_finish

      @page.search_results.first.select_result.click
      @page.selected_video.add_to_queue.click()
      wait_for_angular_requests_to_finish

      @page.add_video.click
      sleep 1

      expect(@page.selected_video.cancel['disabled']).to be_blank
    end
  end
end

shared_examples "video shows duration" do
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

  it_behaves_like "the video show index page"
  it_behaves_like "video shows duration"
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

  it_behaves_like "the video show index page"
  it_behaves_like "video shows duration"
end

# Check when accessing a non-logged in user
describe 'Not Logged In: /#/shows/:show_id/videos', js: true, type: :feature do
  it_behaves_like "guest_access" do
    let(:loader) { VideosShowsIndexPage.new.load(show_id: 1) }
  end
end
