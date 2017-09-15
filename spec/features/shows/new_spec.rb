require 'rails_helper'

describe 'Admin User: /#/shows/new', js: true, type: :feature do
  let(:user1) { create_user() }
  let(:user2) { create_user(role_titles: [:host]) }
  let(:user3) { create_user(role_titles: [:host, :admin]) }
  let(:user4) { create_user(requires_auth: true) }
  let(:preload) { user1; user2; user3 }

  before do
    preload if defined?(preload)
    sign_in_admin
    @page = ShowsNewPage.new
    @page.load
    wait_for_angular_requests_to_finish
    @form = @page.form
  end

  it_behaves_like 'admin menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Shows' }
  end

  it 'validates' do
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

    expect(page.current_url).to end_with("/#/shows")
  end

  it 'creates a new show with one host for today' do
    @form.title.set('New Show Title')
    @form.air_date.click
    @page.sec_air_date.select_today
    expect(Date.today.to_s(:db)).to eq(@form.air_date.value)

    source = @form.find_host(user1, :sec_available_hosts).root_element
    target = @form.show_hosts
    source.drag_to(target)

    @form.submit.click
    wait_for_angular_requests_to_finish

    # Goes to the videos page
    new_show = Show.where(title: 'New Show Title').last
    expect(page.current_url).to end_with("/#/shows/#{new_show.id}/videos")

    # Check that it shows up on index after create
    @index_page = ShowsIndexPage.new
    @index_page.load
    wait_for_angular_requests_to_finish

    expect(@index_page.notices.collect(&:text)).to include("Successfully Created Show")

    show = @index_page.find_show(new_show)
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
    @page.sec_air_date.select_date(date)
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
    expect(page.current_url).to end_with("/#/shows/#{new_show.id}/videos")

    # Check that it shows up on index after create
    @index_page = ShowsIndexPage.new
    @index_page.load
    wait_for_angular_requests_to_finish

    expect(@index_page.notices.collect(&:text)).to include("Successfully Created Show")

    show = @index_page.find_show(new_show)
    expect(show.show_id.text).to eq(new_show.id.to_s)
    expect(show.title.text).to eq("New Show Title 2")
    expect(show.air_date.text).to eq((Date.today + 3.months + 2.days).to_s(:db))
    expect(show.video_count.text).to eq('0')
    expect(new_show.users).to include(user1)
    expect(new_show.users).to include(user2)
  end
end

describe 'Admin User (requires auth): /#/shows/new', js: true, type: :feature do
  let(:current_user) { create_user(role_titles: [:admin], requires_auth: true) }
  before do
    sign_in(current_user)
    @page = ShowsNewPage.new
    @page.load
    sleep 1
    wait_for_angular_requests_to_finish
  end

  it_behaves_like "requires_auth"
end

describe 'Host User: /#/shows/new', js: true, type: :feature do
  before do
    preload if defined?(preload)
    sign_in_host
    @page = ShowsNewPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'host menu' do
    let(:menu) { @page.menu }
    let(:active) { 'Shows' }
  end

  it_behaves_like "unauthorized"
end

describe 'Host User (requires auth): /#/shows/new', js: true, type: :feature do
  let(:current_user) { create_user(role_titles: [:host], requires_auth: true) }
  before do
    sign_in(current_user)
    @page = ShowsNewPage.new
    @page.load
    sleep 1
    wait_for_angular_requests_to_finish
  end

  it_behaves_like "requires_auth"
end

describe 'Not Logged In: /#/shows/new', js: true, type: :feature do
  before do
    preload if defined?(preload)
    @page = ShowsNewPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'guest menu' do
    let(:menu) { @page.menu }
  end

  it_behaves_like "guest_access"
end
