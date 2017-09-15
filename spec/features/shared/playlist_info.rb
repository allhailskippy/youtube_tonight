#
# Must define these ahead of time:
# playlist_info: The PlaylistInfoSection object being tested
# playlist:      The playlist that should be displayed
#
# Example Usage:
#  it_should_behave_like "playlist_info" do
#    let(:playlist_info) { @page.playlist_info }
#    let(:playlist) { playlist }
#  end
#
shared_examples "playlist_info" do
  it 'has the playlist info section' do
    expect(playlist_info.playlist_image['src']).to eq(playlist.api_thumbnail_default_url)
    expect(playlist_info.playlist_id.text).to eq(playlist.id.to_s)
    expect(playlist_info.title.text).to eq(playlist.api_title.to_s)
    expect(playlist_info.video_count.text).to eq(playlist.video_count.to_s)
  end
end
