require 'rails_helper'

describe 'Admin User: /app#/shows/index', js: true, type: :feature do
  subject { page }

  let(:admin) { create_user() }
  let(:host1) { create_user(role_titles: [:host]) }
  let(:host2) { create_user(role_titles: [:host]) }
  let(:host3) { create_user(role_titles: [:host]) }
  let(:show1) { create(:show_with_videos, hosts: "#{host1.id}") }
  let(:show2) { create(:show_with_videos, hosts: [host1.id, host2.id].join(',')) }
  let(:show3) { create(:show_with_videos, hosts: "#{host3.id}", video_count: 7) }
  let(:preload) { admin; host1; host2; host3; show1; show2; show3 }

  before do
    preload if defined?(preload)
    sign_in(admin)
    @shows_index_page = ShowsIndexPage.new
    @shows_index_page.load
    wait_for_angular_requests_to_finish
  end

  it 'gets the index' do
    expect(@shows_index_page.rows.length).to eq(3)

    @shows_index_page.rows.each do |row|
      show = Show.find(row.show_id.text.to_i)
      expect(row.show_id.text).to eq(show.id.to_s)
      expect(row.title.text).to eq(show.title)
      expect(row.air_date.text).to eq(show.air_date.to_s(:db))
      expect(row.video_count.text).to eq(show.videos.count.to_s)
    end
  end

  it 'goes to create a new show' do
    @shows_index_page.create_show.click()
    expect(page.current_url).to end_with("/app#/shows/new")
  end

  describe 'actions' do
    it 'has all the right buttons' do
      [show1, show2, show3].each do |show|
        row = @shows_index_page.find_row(show)
        expected = row.sec_actions.edit['ng-click']
        expect(expected).to eq('edit(show)')
        expected = row.sec_actions.videos['href']
        expect(expected).to end_with("/app#/videos/shows/#{show.id}")
      end
    end

    describe 'goes to edit' do
      it 'goes to edit for show1' do
        row = @shows_index_page.find_row(show1)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/app#/shows/#{show1.id}/edit")
      end

      it 'goes to edit for show2' do
        row = @shows_index_page.find_row(show2)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/app#/shows/#{show2.id}/edit")
      end

      it 'goes to edit for show3' do
        row = @shows_index_page.find_row(show3)
        row.sec_actions.edit.click()
        expect(page.current_url).to end_with("/app#/shows/#{show3.id}/edit")
      end
    end

    describe 'videos' do
      it 'goes for show1' do
        row = @shows_index_page.find_row(show1)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/app#/videos/shows/#{show1.id}")
      end

      it 'goes for show2' do
        row = @shows_index_page.find_row(show2)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/app#/videos/shows/#{show2.id}")
      end

      it 'goes for show3' do
        row = @shows_index_page.find_row(show3)
        row.sec_actions.videos.click()
        expect(page.current_url).to end_with("/app#/videos/shows/#{show3.id}")
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
#    @users_index_page = UsersIndexPage.new
#    @users_index_page.load
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
#    @users_index_page = UsersIndexPage.new
#    @users_index_page.load
#    wait_for_angular_requests_to_finish
#
#    expect(page.current_url).to include("/users/sign_in")
#  end
#end