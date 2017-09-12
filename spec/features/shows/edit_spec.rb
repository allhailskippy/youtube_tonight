require 'rails_helper'

describe 'Admin User: /app#/shows/:show_id/edit', js: true, type: :feature do
  subject { page }
  let(:user1) { create_user() }
  let(:user2) { create_user(role_titles: [:host]) }
  let(:user3) { create_user(role_titles: [:host, :admin]) }
  let(:user4) { create_user(requires_auth: true) }
  let(:show) do
    create(:show_with_videos,
      title: 'Starting Title',
      air_date: Date.today,
      users: [user1, user2],
      video_count: 3
    ) 
  end
  let(:preload) { user1; user2; user3 }

  before do
    preload if defined?(preload)
    sign_in_admin
    @page= ShowsEditPage.new
    @page.load(show_id: show.id)
    wait_for_angular_requests_to_finish
    @form = @page.form
  end

  it 'validates' do
    # Clear existing data
    @form.title.set('')
    @form.air_date.set('')
    @form.title.click # to clear the air date pop up
    sleep 1

    @form.show_hosts_source.each do |src|
      target = @form.available_hosts
      src.drag_to(target)
    end

    @form.submit.click
    wait_for_angular_requests_to_finish

    errors = @page.errors.collect(&:text)
    expect(errors).to include("Title can't be blank")
    expect(errors).to include("Air date is not a date")
    expect(errors).to include("Host must be selected")
  end

  it 'cancels' do
    @page.cancel.click
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with("/app#/shows/index")
  end

  it 'deletes' do
    accept_confirm do
      @page.delete.click
    end
    wait_for_angular_requests_to_finish

    expect { Show.find(show.id) }.to raise_error(ActiveRecord::RecordNotFound)
    expect(page.current_url).to end_with("/app#/shows/index")
  end

  it 'cancels delete' do
    dismiss_confirm do
      @page.delete.click
    end

    expect(Show.find(show.id)).to eq(show)
    expect(page.current_url).to end_with("/app#/shows/#{show.id}/edit")
  end

  it 'edits a show' do
    # Current data is correct
    expect(@form.title.value).to eq('Starting Title')
    expect(@form.air_date.value).to eq(Date.today.to_s(:db))
    [user1, user2].each do |user|
      userinfo = @form.find_host(user)
      expect(userinfo.user_id.text).to eq(user.id.to_s)
    end

    # Change data
    @form.title.set('Edited Show Title')
    @form.air_date.click
    @page.sec_air_date.select_today
    expect(Date.today.to_s(:db)).to eq(@form.air_date.value)

    # Bring user3 over
    source = @form.find_host(user3, :sec_available_hosts).root_element
    target = @form.show_hosts
    source.drag_to(target)

    # Take user1 off
    source = @form.find_host(user1).root_element
    target = @form.available_hosts
    source.drag_to(target)

    @form.submit.click
    wait_for_angular_requests_to_finish

    # Goes to the videos page
    edited_show = Show.find(show.id)
    expect(page.current_url).to end_with("/app#/shows/index")

    # Check that it shows up on index after upate
    @index_page = ShowsIndexPage.new
    wait_for_angular_requests_to_finish
    expect(@index_page.notices.collect(&:text)).to include("Successfully Updated Show")

    show = @index_page.find_show(edited_show)
    expect(show.show_id.text).to eq(edited_show.id.to_s)
    expect(show.title.text).to eq("Edited Show Title")
    expect(show.air_date.text).to eq(Date.today.to_s(:db))
    expect(show.video_count.text).to eq("3")
    expect(edited_show.users).to include(user2)
    expect(edited_show.users).to include(user3)
    expect(edited_show.users).not_to include(user1)
  end
end

describe 'Host User: /app#/shows/:show_id/edit', js: true, type: :feature do
  subject { page }
  let(:show) { create(:show) }
  let(:preload) { show }

  before do
    preload if defined?(preload)
    sign_in_host
  end

  it 'does not get the edit page' do
    @page= ShowsEditPage.new
    @page.load(show_id: show.id)
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with("/app#/unauthorized")
  end
end

describe 'Not Logged In: /app#/shows/:show_id/edit', js: true, type: :feature do
  subject { page }
  let(:show) { create(:show) }
  let(:preload) { show }

  before do
    preload if defined?(preload)
  end

  it 'goes to sign in' do
    @page= ShowsEditPage.new
    @page.load(show_id: show.id)
    wait_for_angular_requests_to_finish

    expect(page.current_url).to include("/users/sign_in")
  end
end
