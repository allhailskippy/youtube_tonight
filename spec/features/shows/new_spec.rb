require 'rails_helper'

describe 'Admin User: /app#/shows/new', js: true, type: :feature do
  subject { page }
  let(:user1) { create_user() }
  let(:user2) { create_user(role_titles: [:host]) }
  let(:user3) { create_user(role_titles: [:host, :admin]) }
  let(:user4) { create_user(requires_auth: true) }
  let(:preload) { user1; user2; user3 }

  before do
    preload if defined?(preload)
    sign_in_admin
    @shows_new_page= ShowsNewPage.new
    @shows_new_page.load()
    wait_for_angular_requests_to_finish
    @form = @shows_new_page.form
  end

  it 'validates' do
    @form.submit.click
    wait_for_angular_requests_to_finish

    errors = @shows_new_page.errors.collect(&:text)
    expect(errors).to include("Title can't be blank")
    expect(errors).to include("Air date is not a date")
    expect(errors).to include("Host must be selected")
  end

  it 'cancels' do
    @shows_new_page.cancel.click
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with("/app#/shows/index")
  end

  it 'creates a new show with one host for today' do
    @form.title.set('New Show Title')
    @form.air_date.click
    @shows_new_page.sec_air_date.select_today
    expect(Date.today.to_s(:db)).to eq(@form.air_date.value)

    source = @form.find_host(user1, :sec_available_hosts).root_element
    target = @form.show_hosts
    source.drag_to(target)

    @form.submit.click
    wait_for_angular_requests_to_finish

    # Goes to the videos page
    new_show = Show.where(title: 'New Show Title').last
    expect(page.current_url).to end_with("/app#/videos/shows/#{new_show.id}")

    # Check that it shows up on index after create
    @shows_index_page = ShowsIndexPage.new
    @shows_index_page.load
    wait_for_angular_requests_to_finish

    expect(@shows_index_page.notices.collect(&:text)).to include("Successfully Created Show")

    show = @shows_index_page.find_show(new_show)
    expect(show.show_id.text).to eq(new_show.id.to_s)
    expect(show.title.text).to eq("New Show Title")
    expect(show.air_date.text).to eq(Date.today.to_s(:db))
    expect(show.video_count.text).to eq('0')
    expect(new_show.users).to include(user1)
  end

  it 'creates a new show with two hosts for the future' do
    @form.title.set('New Show Title 2')
    @form.air_date.click
    date = Date.today + 3.months + 2.days
    @shows_new_page.sec_air_date.select_date(date)
    expect(date.to_s(:db)).to eq(@form.air_date.value)

    target = @form.show_hosts
    source = @form.find_host(user1, :sec_available_hosts).root_element
    source.drag_to(target)
    source = @form.find_host(user2, :sec_available_hosts).root_element
    source.drag_to(target)

    @form.submit.click
    wait_for_angular_requests_to_finish

    # Goes to the videos page
    new_show = Show.where(title: 'New Show Title 2').last
    expect(page.current_url).to end_with("/app#/videos/shows/#{new_show.id}")

    # Check that it shows up on index after create
    @shows_index_page = ShowsIndexPage.new
    @shows_index_page.load
    wait_for_angular_requests_to_finish

    expect(@shows_index_page.notices.collect(&:text)).to include("Successfully Created Show")

    show = @shows_index_page.find_show(new_show)
    expect(show.show_id.text).to eq(new_show.id.to_s)
    expect(show.title.text).to eq("New Show Title 2")
    expect(show.air_date.text).to eq((Date.today + 3.months + 2.days).to_s(:db))
    expect(show.video_count.text).to eq('0')
    expect(new_show.users).to include(user1)
    expect(new_show.users).to include(user2)
  end
end

describe 'Host User: /app#/shows/new', js: true, type: :feature do
  subject { page }

  before do
    preload if defined?(preload)
    sign_in_host
  end

  it 'does not get the new page' do
    @shows_new_page = ShowsNewPage.new
    @shows_new_page.load()
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with("/app#/unauthorized")
  end
end

describe 'Not Logged In: /app#/shows/new', js: true, type: :feature do
  subject { page }

  before do
    preload if defined?(preload)
  end

  it 'goes to sign in' do
    @shows_new_page = ShowsNewPage.new
    @shows_new_page.load
    wait_for_angular_requests_to_finish

    expect(page.current_url).to include("/users/sign_in")
  end
end
