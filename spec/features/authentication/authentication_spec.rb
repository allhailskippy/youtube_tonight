require 'rails_helper'

describe 'Admin User: /users/sign_in', js: true, type: :feature do
  let(:admin) { create_user(role_titles: [:admin]) }
  let(:preload) { admin }

  before do
    preload if defined?(preload)
    sign_in(admin)
    @page = AuthPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it 'is already logged in' do
    expect(page.current_url).to end_with('/#/shows')
  end

  it 'can log out' do
    @page.menu.logout.click
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with('/users/sign_in')
  end
end

describe 'Host User: /users/sign_in', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:preload) { host }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = AuthPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it 'is already logged in' do
    expect(page.current_url).to end_with('/#/shows')
  end

  it 'can log out' do
    @page.menu.logout.click
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with('/users/sign_in')
  end
end

describe 'Not Logged In: /users/sign_in', js: true, type: :feature do
  before do
    preload if defined?(preload)
    @page = AuthPage.new
    @page.load
    wait_for_angular_requests_to_finish
  end

  it 'logs in with new user' do
    set_omniauth
    expect(page.current_url).to end_with('/users/sign_in')

    @page.sign_in.click
    wait_for_angular_requests_to_finish

    new_user = User.last
    expect(page.current_url).to end_with("/users/#{new_user.id}/requires_auth")
  end

  it 'sends an email on new log in' do
    admin_user = create_user(role_titles: [:admin], email: 'admin@fakeemail.com')

    set_omniauth
    deliveries = ActionMailer::Base.deliveries
    delivery_count = deliveries.count

    @page.sign_in.click
    wait_for_angular_requests_to_finish

    new_user = User.last
    expect(deliveries.count).to eq(delivery_count + 1)


    delivery = deliveries.last

    expect(delivery.to).to eq([admin_user.email])
    expect(delivery.from).to eq(["yttonight@gmail.com"])
    expect(delivery[:from].display_names).to eq(['YouTube Tonight'])
    expect(delivery.subject).to eq("New user registration at YouTube Tonight")
    expect(delivery.body).to include("<h1>#{new_user.name} <#{new_user.email}> has registered at YouTube tonight</h1>")
    expect(delivery.body).to include("<a href=\"http://example.com/#/users\">Go here</a> to authorize.")
  end

  it 'logs in with existing user' do
    user = create_user(role_titles: [:admin])
    set_omniauth(user)
    expect(page.current_url).to end_with('/users/sign_in')

    @page.sign_in.click
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with("/#/shows")
  end

  it 'logs in with existing user that requires auth' do
    user = create_user(role_titles: [:admin], requires_auth: true)
    set_omniauth(user)
    expect(page.current_url).to end_with('/users/sign_in')

    @page.sign_in.click
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with("/users/#{user.id}/requires_auth")
  end
end
