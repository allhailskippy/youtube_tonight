shared_examples "preview_player" do
  # Using real video information here
  let(:video1) do
    Video.create({
      parent: parent,
      title: 'We do something new',
      link: 'https://www.youtube.com/v/fXp-299i4mw',
      api_video_id: 'fXp-299i4mw',
      api_channel_id: 'UCSaLiUL_ICoYtisQgIK_cSA',
      api_channel_title: 'Paul Mason',
      api_thumbnail_medium_url: 'https://i.ytimg.com/vi/fXp-299i4mw/mqdefault.jpg',
      api_thumbnail_default_url: 'https://i.ytimg.com/vi/fXp-299i4mw/default.jpg',
      api_thumbnail_high_url: 'https://i.ytimg.com/vi/fXp-299i4mw/hqdefault.jpg',
      api_title: 'We do something new',
      api_duration: 'PT1M24S',
      api_duration_seconds: 84
    })
  end

  let(:video2) do
    Video.create({
      parent: parent,
      title: "I explain what's the deal",
      link: 'https://www.youtube.com/v/FdyReQRUUJM',
      api_video_id: 'FdyReQRUUJM',
      api_channel_id: 'UCSaLiUL_ICoYtisQgIK_cSA',
      api_channel_title: 'Paul Mason',
      api_thumbnail_medium_url: 'https://i.ytimg.com/vi/FdyReQRUUJM/mqdefault.jpg',
      api_thumbnail_default_url: 'https://i.ytimg.com/vi/FdyReQRUUJM/default.jpg',
      api_thumbnail_high_url: 'https://i.ytimg.com/vi/FdyReQRUUJM/hqdefault.jpg',
      api_title: "I explain what's the deal",
      api_duration: 'PT1M48S',
      api_duration_seconds: 108
    })
  end

  let(:preload) { video1; video2 }

  it 'toggles the preview' do
    VideoPlayerChannel.any_instance.expects(:play).once

    row = @page.find_row(video1)
    row.preview_start.click
    wait_for_angular_requests_to_finish

    player_id = @page.preview_area["player-id"]
    sender_id = row.thumbnail_area["sender-id"]

    VideoPlayerChannel.broadcast_to('video_player', { action: 'playing', message: { player_id: player_id, sender_id: sender_id }})

    using_wait_time(0) do
      expect{ row.preview_start }.to raise_error(Capybara::ElementNotFound)
    end
    expect(row.preview_stop['class']).to_not include('disabled')

    VideoPlayerChannel.broadcast_to('video_player', { action: 'stopped', message: { player_id: player_id, sender_id: sender_id }})

    expect(row.preview_start['class']).to_not include('disabled')
    using_wait_time(0) do
      expect{ row.preview_stop }.to raise_error(Capybara::ElementNotFound)
    end
  end

  it 'starts a new preview while one is already running' do
    VideoPlayerChannel.any_instance.expects(:stopped).once

    row1 = @page.find_row(video1)
    row2 = @page.find_row(video2)
    player_id = @page.preview_area["player-id"]
    sender_id = row1.thumbnail_area["sender-id"]

    row1.preview_start.click
    wait_for_angular_requests_to_finish
    sleep 1

    VideoPlayerChannel.broadcast_to('video_player', { action: 'playing', message: { player_id: player_id, sender_id: sender_id }})
    sleep 1 

    # first video should show as playing
    using_wait_time(0) do
      expect{ row1.preview_start }.to raise_error(Capybara::ElementNotFound)
    end
    expect(row1.preview_stop['class']).to_not include('disabled')
    expect(row2.preview_start['class']).to_not include('disabled')
    using_wait_time(0) do
      expect{ row2.preview_stop }.to raise_error(Capybara::ElementNotFound)
    end

    row2.preview_start.click
    wait_for_angular_requests_to_finish
    VideoPlayerChannel.broadcast_to('video_player', { action: 'stopped', message: { player_id: player_id, sender_id: sender_id }})
    sender_id = row2.thumbnail_area["sender-id"]
    VideoPlayerChannel.broadcast_to('video_player', { action: 'playing', message: { player_id: player_id, sender_id: sender_id }})
    sleep 1

    # second video should now show as playing
    expect(row1.preview_start['class']).to_not include('disabled')
    using_wait_time(0) do
      expect{ row1.preview_stop }.to raise_error(Capybara::ElementNotFound)
    end
    using_wait_time(0) do
      expect{ row2.preview_start }.to raise_error(Capybara::ElementNotFound)
    end
    expect(row2.preview_stop['class']).to_not include('disabled')
  end

  it 'toggles control button enabled state' do
    row = @page.find_row(video1)

    # Controls should start disabled
    controls = @page.preview_controls
    expect(controls.slider['disabled']).to be_truthy
    expect(controls.pause['disabled']).to be_truthy
    expect(controls.stop['disabled']).to be_truthy
    expect(controls.mute['disabled']).to be_truthy
    using_wait_time(0) do
      expect{ controls.play }.to raise_error(Capybara::ElementNotFound)
      expect{ controls.unmute }.to raise_error(Capybara::ElementNotFound)
    end

    row.preview_start.click
    wait_for_angular_requests_to_finish

    player_id = @page.preview_area["player-id"]
    sender_id = row.thumbnail_area["sender-id"]

    sleep 2
    
    # Controls should be enabled
    expect(controls.slider['disabled']).to be_blank
    expect(controls.pause['disabled']).to be_blank
    expect(controls.stop['disabled']).to be_blank
    expect(controls.unmute['disabled']).to be_blank
    using_wait_time(0) do
      expect{ controls.play }.to raise_error(Capybara::ElementNotFound)
      expect{ controls.mute }.to raise_error(Capybara::ElementNotFound)
    end

    # Toggle pause
    controls.pause.click
    sleep 2
    expect(controls.play['disabled']).to be_blank
    expect{ controls.pause }.to raise_error(Capybara::ElementNotFound)

    controls.play.click
    sleep 2
    expect(controls.pause['disabled']).to be_blank
    expect{ controls.play }.to raise_error(Capybara::ElementNotFound)

    # Toggle mute
    controls.unmute.click
    sleep 2
    expect(controls.mute['disabled']).to be_blank
    expect{ controls.unmute }.to raise_error(Capybara::ElementNotFound)

    controls.mute.click
    sleep 2
    expect(controls.unmute['disabled']).to be_blank
    expect{ controls.mute }.to raise_error(Capybara::ElementNotFound)

    # Stop disables controls
    controls.stop.click
    sleep 2
    expect(controls.slider['disabled']).to be_truthy
    expect(controls.pause['disabled']).to be_truthy
    expect(controls.stop['disabled']).to be_truthy
    expect(controls.mute['disabled']).to be_truthy
    using_wait_time(0) do
      expect{ controls.play }.to raise_error(Capybara::ElementNotFound)
      expect{ controls.unmute }.to raise_error(Capybara::ElementNotFound)
    end
  end
end
