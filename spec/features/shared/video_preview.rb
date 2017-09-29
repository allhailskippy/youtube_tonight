shared_examples "preview_player" do
  let(:preload) {
    # To avoid state getting overridden
    VideoPlayerChannel.any_instance.stubs(:get_current_state)
    VideoPlayerChannel.any_instance.stubs(:current_state)
    video1; video2
  }

  it 'toggles the preview' do
    VideoPlayerChannel.any_instance.expects(:play).once

    row = @page.find_row(video1)
    row.preview_start.click
    wait_for_angular_requests_to_finish

    player_id = @page.preview_area["player-id"]
    sender_id = row.thumbnail_area["sender-id"]

    VideoPlayerChannel.broadcast_to('video_player', { action: 'playing', message: { player_id: player_id, sender_id: sender_id }})

    wait_until do
      !row.preview_stop['class'].include?('disabled')
    end
    using_wait_time(0) do
      expect{ row.preview_start }.to raise_error(Capybara::ElementNotFound)
    end
    expect(row.preview_stop['class']).to_not include('disabled')

    VideoPlayerChannel.broadcast_to('video_player', { action: 'stopped', message: { player_id: player_id, sender_id: sender_id }})

    wait_until do
      !row.preview_start['class'].include?('disabled')
    end
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

    VideoPlayerChannel.broadcast_to('video_player', { action: 'playing', message: { player_id: player_id, sender_id: sender_id }})
    wait_until do
      !row1.preview_stop['class'].include?('disabled')
    end

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
    wait_until do
      !row1.preview_start['class'].include?('disabled')
    end

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

    # Plays video
    VideoPlayerChannel.any_instance.expects(:play).once

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
    sleep 1

    player_id = @page.preview_area["player-id"]
    sender_id = @page.preview_controls.container["sender-id"]

    VideoPlayerChannel.broadcast_to('video_player', { action: 'playing', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) }})
    VideoPlayerChannel.broadcast_to('video_player', { action: 'current_state', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) , 'paused': false, 'mute': true, playing: true}})

    wait_until do
      controls.slider['disabled'].blank?
    end

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
    VideoPlayerChannel.any_instance.expects(:pause).once
    VideoPlayerChannel.any_instance.expects(:unpause).once

    controls.pause.click
    VideoPlayerChannel.broadcast_to('video_player', { action: 'paused', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) }})
    VideoPlayerChannel.broadcast_to('video_player', { action: 'current_state', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) , 'paused': true, 'mute': true, playing: true}})

    wait_until do
      controls.play['disabled'].blank?
    end
    expect(controls.play['disabled']).to be_blank
    expect{ controls.pause }.to raise_error(Capybara::ElementNotFound)

    controls.play.click
    VideoPlayerChannel.broadcast_to('video_player', { action: 'playing', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) }})
    VideoPlayerChannel.broadcast_to('video_player', { action: 'current_state', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) , 'paused': false, 'mute': true, playing: true}})
    wait_until do
      controls.pause['disabled'].blank?
    end
    expect(controls.pause['disabled']).to be_blank
    expect{ controls.play }.to raise_error(Capybara::ElementNotFound)

    # Toggle mute
    VideoPlayerChannel.any_instance.expects(:unmute).once
    controls.unmute.click
    VideoPlayerChannel.broadcast_to('video_player', { action: 'unmute', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) }})
    VideoPlayerChannel.broadcast_to('video_player', { action: 'current_state', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) , 'paused': false, 'mute': false, playing: true}})
    wait_until do
      controls.mute['disabled'].blank?
    end
    expect(controls.mute['disabled']).to be_blank
    expect{ controls.unmute }.to raise_error(Capybara::ElementNotFound)

    VideoPlayerChannel.any_instance.expects(:mute).once
    controls.mute.click
    VideoPlayerChannel.broadcast_to('video_player', { action: 'nmute', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) }})
    VideoPlayerChannel.broadcast_to('video_player', { action: 'current_state', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) , 'paused': false, 'mute': true, playing: true}})
    wait_until do
      controls.unmute['disabled'].blank?
    end
    expect(controls.unmute['disabled']).to be_blank
    expect{ controls.mute }.to raise_error(Capybara::ElementNotFound)

    # Stop disables controls
    VideoPlayerChannel.any_instance.expects(:stop).once

    controls.stop.click
    VideoPlayerChannel.broadcast_to('video_player', { action: 'stopped', message: { player_id: player_id, sender_id: sender_id, video: JSON.parse(video1.to_json) }})
    VideoPlayerChannel.broadcast_to('video_player', { action: 'current_state', message: { player_id: player_id, sender_id: sender_id, video: nil, 'paused': false, 'mute': false, playing: false}})

    wait_until do
      controls.slider['disabled'].present?
    end
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
