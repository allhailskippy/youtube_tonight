require 'rails_helper'

describe 'Admin User: /#/shows', js: true, type: :feature do
  let(:host1) { create_user(role_titles: [:host]) }
  let(:host2) { create_user(role_titles: [:host]) }
  let(:host3) { create_user(role_titles: [:host]) }
  let(:show1) { create(:show_with_videos, hosts: "#{host1.id}") }
  let(:show2) { create(:show_with_videos, hosts: [host1.id, host2.id].join(',')) }
  let(:show3) { create(:show_with_videos, hosts: "#{host3.id}", video_count: 7) }
  let(:preload) { host1; host2; host3; show1; show2; show3 }

  before do
    preload if defined?(preload)
    sign_in_admin
    @page = ShowsIndexPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it 'gets the index' do
    expect(@page.rows.length).to eq(3)

    @page.rows.each do |row|
      show = Show.find(row.show_id.text.to_i)
      expect(row.show_id.text).to eq(show.id.to_s)
      expect(row.title.text).to eq(show.title)
      expect(row.air_date.text).to eq(show.air_date.to_s(:db))
      expect(row.video_count.text).to eq(show.videos.count.to_s)
    end
  end

  it 'goes to create a new show' do
    @page.create_show.click()
    expect(page.current_url).to end_with("/#/shows/new")
  end

  describe 'actions' do
    it 'has all the right buttons' do
      [show1, show2, show3].each do |show|
        row = @page.find_show(show)
        expected = row.sec_actions.edit['ng-click']
        expect(expected).to eq('edit(show)')
        expected = row.sec_actions.videos['href']
        expect(expected).to end_with("/#/shows/#{show.id}/videos")
      end
    end

    describe 'goes to edit' do
      it 'goes to edit for show1' do
        row = @page.find_show(show1)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/#/shows/#{show1.id}/edit")
      end

      it 'goes to edit for show2' do
        row = @page.find_show(show2)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/#/shows/#{show2.id}/edit")
      end

      it 'goes to edit for show3' do
        row = @page.find_show(show3)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/#/shows/#{show3.id}/edit")
      end
    end

    describe 'videos' do
      it 'goes for show1' do
        row = @page.find_show(show1)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/#/shows/#{show1.id}/videos")
      end

      it 'goes for show2' do
        row = @page.find_show(show2)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/#/shows/#{show2.id}/videos")
      end

      it 'goes for show3' do
        row = @page.find_show(show3)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/#/shows/#{show3.id}/videos")
      end
    end
  end
end

describe 'Host User: /#/shows', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:show1) { create(:show, users: [host]) }
  let(:show2) { create(:show, users: [host]) }
  let(:show3) { create(:show) }
  let(:preload) { show1; show2; show3 }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = ShowsIndexPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it 'gets the shows the user can host' do
    expect(@page.rows.length).to eq(2)

    [show1, show2].each do |show|
      row = @page.find_show(show)

      expect(row.show_id.text).to eq(show.id.to_s)
      expect(row.title.text).to eq(show.title)
      expect(row.air_date.text).to eq(show.air_date.to_s(:db))
      expect(row.video_count.text).to eq(show.videos.count.to_s)
    end

    expect(@page.find_show(show3)).to be_nil
  end

  it 'does not have the create button' do
    expect { @page.create_show }.to raise_error(Capybara::ElementNotFound)
  end

  it 'does not have the edit button' do
    [show1, show2].each do |show|
      row = @page.find_show(show)
      expect { row.sec_actions.edit }.to raise_error(Capybara::ElementNotFound)
    end
  end

  it 'has the videos button' do
    [show1, show2].each do |show|
      row = @page.find_show(show)
      expected = row.sec_actions.videos['href']
      expect(expected).to end_with("/#/shows/#{show.id}/videos")
    end
  end

  describe 'videos' do
    it 'goes for show1' do
      row = @page.find_show(show1)
      row.sec_actions.videos.click()
      expect(page.current_url).to end_with("/#/shows/#{show1.id}/videos")
    end

    it 'goes for show2' do
      row = @page.find_show(show2)
      row.sec_actions.videos.click()
      expect(page.current_url).to end_with("/#/shows/#{show2.id}/videos")
    end
  end
end

describe 'Not Logged In: /#/shows', js: true, type: :feature do
  it_behaves_like "guest_access" do
    let(:loader) { ShowsIndexPage.new.load }
  end
end
