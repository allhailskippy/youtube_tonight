require 'rails_helper'

describe 'Admin User: /app#/users/:user_id/edit', js: true, type: :feature do
  subject { page }

  let(:admin) { create_user() }
  let(:user) { create_user(name: 'User 1', email: 'email@test.com', requires_auth: false) }
  let(:preload) { admin; user }

  before do
    preload if defined?(preload)
    sign_in(admin)
    @users_edit_page = UsersEditPage.new
    @users_edit_page.load(user_id: user.id)
    wait_for_angular_requests_to_finish
    @form = @users_edit_page.form
  end

  it 'submits the edit page for admin: requires auth checked' do
    # Initial values are correct
    expect(@form.name.value).to eq(user.name)
    expect(@form.email.value).to eq(user.email)
    expect(@form.requires_auth).not_to be_checked
    expect(@form.role_titles(visible: false).value).to eq(['admin'])

    # Checking 'requires authorization' unsets roles
    @form.name.set('Edited Name')
    @form.email.set('fake@email.com')
    @form.requires_auth.set(true)
    @form.actions.submit.trigger(:click)
    wait_for_angular_requests_to_finish

    # Verify
    u = User.find(user.id)
    expect(u.name).to eq('Edited Name')
    expect(u.email).to eq('fake@email.com')
    expect(u.requires_auth).to eq(true)
    expect(u.role_titles).to eq([])

    expect(page.current_url).to end_with("/users/index")
  end

  it 'submits the edit page for admin: change role to host' do
    # Initial values are correct
    expect(@form.name.value).to eq(user.name)
    expect(@form.email.value).to eq(user.email)
    expect(@form.requires_auth).not_to be_checked
    expect(@form.role_titles(visible: false).value).to eq(['admin'])

    # Checking roles change works
    @form.name.set('Edited Name 2')
    @form.email.set('fake2@email.com')
    @form.select_role('Host')
    @form.actions.submit.trigger(:click)
    wait_for_angular_requests_to_finish

    # Verify
    u = User.find(user.id)
    expect(u.name).to eq('Edited Name 2')
    expect(u.email).to eq('fake2@email.com')
    expect(u.requires_auth).to eq(false)
    expect(u.role_titles).to eq([:admin, :host])

    expect(page.current_url).to end_with("/users/index")
  end

  it 'cancels' do
    @form.name.set('Edited Name 3')
    @form.email.set('fake2@email.com')
    @form.select_role('Host')
    @form.actions.cancel.trigger(:click)

    # Verify no changes have been made
    u = User.find(user.id)
    expect(u.name).to eq('User 1')
    expect(u.email).to eq('email@test.com')
    expect(u.requires_auth).to eq(false)
    expect(u.role_titles).to eq([:admin])

    expect(page.current_url).to end_with("/users/index")
  end

  it 'deletes the user' do
    accept_confirm("This will remove the user from the system\nThis cannot be undone!") do
      @users_edit_page.delete_button.trigger(:click)
    end
    wait_for_angular_requests_to_finish

    expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
    expect(page.current_url).to end_with("/users/index")
  end

  it 'cancels the delete request' do
    dismiss_confirm("This will remove the user from the system\nThis cannot be undone!") do
      @users_edit_page.delete_button.trigger(:click)
    end

    expect(User.find(user.id)).to eq(user)
    expect(page.current_url).to end_with("/app#/users/#{user.id}/edit")
  end
end

describe 'Host User: /app#/users/:user_id/edit', js: true, type: :feature do
  subject { page }

  let(:host) { u = without_access_control { create(:user, role_titles: [:host]) }; User.find(u.id) }
  let(:preload) { host }

  before do
    preload if defined?(preload)
    sign_in(host)
  end

  it 'does not get the edit page' do
    @users_edit_page = UsersEditPage.new
    @users_edit_page.load(user_id: host.id)
    wait_for_angular_requests_to_finish

    expect(page.current_url).to end_with("/app#/unauthorized")
  end
end

describe 'Not Logged In: /app#/users/:users_id/edit', js: true, type: :feature do
  subject { page }

  before do
    preload if defined?(preload)
  end

  it 'goes to sign in' do
    @users_edit_page = UsersEditPage.new
    @users_edit_page.load(user_id: 1)
    wait_for_angular_requests_to_finish

    expect(page.current_url).to include("/users/sign_in")
  end
end
