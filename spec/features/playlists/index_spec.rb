require 'rails_helper'

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

  it "checks default pagination settings " do
    p = @page.pagination
    expected = "Page 1 of 10, of 100 entries"
    expect(p.description.text).to eq(expected)
    expect(p.active_per_page.text).to eq("10")
    expect(p.pages.active.text).to eq("1")
    expect(@page.rows.length).to eq(10)
  end

  it "checks data when flipping pages" do
    p = @page.pagination

    # Should be by id descending
    start_idx = 0
    end_idx = 9
    page_num = 1
    10.times do |i|
      # Check that the correct playlists are shown
      expected = playlists.reverse[start_idx..end_idx].collect(&:api_title)
      expect(@page.rows.collect{|r| r.title.text}).to eq(expected)

      if i < 9
        page_num += 1
        p.find_page(page_num.to_s).click
        wait_for_angular_requests_to_finish

        start_idx += 10
        end_idx += 10
      end
    end
  end

  it 'changes how many per page are returned' do
    p = @page.pagination
    [5, 10, 20, 50].each do |n|
      p.find_per_page(n.to_s).click
      wait_for_angular_requests_to_finish
      expect(@page.rows.length).to eq(n)
    end
  end

  it 'shows the correct page numbers' do
    p = @page.pagination
    range = (0..9)
    range.each do |n|
      start = n <= 2 ? 0 : (n - 2)
      page_num = n + 1
      expected_pages = (range.to_a[start, 5]).map{|x| x += 1}

      # Should typically have 5 + prev + next. Last 2 pages have less
      expected = n < 8 ? 7 : (n < 9 ? 6 : 5)
      expect(p.pages.page_nums.length).to eq(expected)

      expected_pages.each do |pg|
        if pg == page_num
          expect(p.pages.active.text).to eq(page_num.to_s)
        else
          expect(p.find_page(pg.to_s)).to_not be_nil
        end
      end
      if n < range.max
        next_page = (page_num + 1).to_s
        p.find_page(next_page).click
        wait_for_angular_requests_to_finish
      end
    end
  end

  it 'can scroll through the pages if available' do
    p = @page.pagination
    p.find_per_page("5").click
    wait_for_angular_requests_to_finish

    range = (0..19)
    max_to_check = range.max - 2
    min_to_check = 3
    range.each do |n|
      start = n <= 2 ? 0 : (n - 2)
      expected_pages = (range.to_a[start, 5])
      if expected_pages.last < range.max
        # Check that it can scroll all the way to the end
        while start + 4 < range.max
          start = expected_pages.last + 1
          expected_pages = (start..start + 4)
          if expected_pages.max <= range.max
            p.pages.next.click
          end
        end

        # Scroll back to beginning
        while start > 0
          if expected_pages.min > 0
            p.pages.previous.click
          end
          start -= 5
          start = 0 if start < 0
          expected_pages = (start..start+4)
        end

        expect(p.pages.previous_disabled).to_not be_nil

        # And then back up until the current page
        while !expected_pages.include?(n)
          start = expected_pages.last + 1
          expected_pages = (start..start + 4)
          p.pages.next.click
        end

        # If the current page is the last one showing,
        # we need to hit the 'next' button once more
        if n == expected_pages.max
          p.pages.next.click
        end
      else
        expect(p.pages.next_disabled).to_not be_nil
      end
      if n < range.max
        page_num = n + 1
        next_page = (page_num + 1).to_s
        p.find_page(next_page).click
        wait_for_angular_requests_to_finish
      end
    end
  end
end
#
#describe 'Host User: /app#/users/index', js: true, type: :feature do
#  subject { page }
#
#  let(:host) { create_user(role_titles: [:host]) }
#  let(:preload) { host }
#
#  before do
#    preload if defined?(preload)
#    sign_in(host)
#  end
#
#  it 'does not get the index' do
#    @page = PlaylistsIndexPage.new
#    @page.load
#    wait_for_angular_requests_to_finish
#
#    expect(page.current_url).to end_with("/app#/unauthorized")
#  end
#end
#
#describe 'Not Logged In: /app#/users/index', js: true, type: :feature do
#  subject { page }
#
#  before do
#    preload if defined?(preload)
#  end
#
#  it 'goes to sign in' do
#    @page = PlaylistsIndexPage.new
#    @page.load
#    wait_for_angular_requests_to_finish
#
#    expect(page.current_url).to include("/users/sign_in")
#  end
#end
