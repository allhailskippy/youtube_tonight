require 'rails_helper'

describe 'Admin User: /#/users/:user_id/edit', js: true, type: :feature do
  describe 'Standard behaviour' do
    let(:user) { create_user(name: 'User 1', email: 'email@test.com', requires_auth: false) }
    let(:preload) { user }

    before do
      preload if defined?(preload)
      sign_in_admin
      @page = UsersEditPage.new
      @page.load(user_id: user.id)
      wait_for_angular_requests_to_finish
      @form = @page.form
    end

    it_behaves_like 'admin menu' do
      let(:menu) { @page.menu }
      let(:active) { 'Users' }
    end

    describe 'validation' do
      it 'must have a user name and email' do
        @form.name.set('')
        @form.email.set('')
        @form.actions.submit.click
        wait_for_angular_requests_to_finish

        errors = @page.errors.collect(&:text)
        expect(errors).to include("Name can't be blank")
        expect(errors).to include("Email can't be blank")
      end

      # TID-98
      it 'Clears error messages between pages' do
        @form.name.set('')
        @form.actions.submit.click
        wait_for_angular_requests_to_finish

        errors = @page.errors.collect(&:text)
        expect(errors).to include("Name can't be blank")

        @page.menu.shows.click()
        wait_for_angular_requests_to_finish

        @page = ShowsIndexPage.new
        expect(@page.errors).to be_blank
      end
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
      @form.actions.submit.click
      wait_for_angular_requests_to_finish

      # Verify
      u = User.find(user.id)
      expect(u.name).to eq('Edited Name')
      expect(u.email).to eq('fake@email.com')
      expect(u.requires_auth).to eq(true)
      expect(u.role_titles).to eq([])

      expect(page.current_url).to end_with("/users")
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
      @form.click_role('Host')
      @form.actions.submit.click
      wait_for_angular_requests_to_finish

      # Verify
      u = User.find(user.id)
      expect(u.name).to eq('Edited Name 2')
      expect(u.email).to eq('fake2@email.com')
      expect(u.requires_auth).to eq(false)
      expect(u.role_titles).to eq([:admin, :host])

      expect(page.current_url).to end_with("/users")
    end

    it 'should get an error when removing all hosts' do
      @form.click_role('Admin')
      @form.actions.submit.click
      wait_for_angular_requests_to_finish

      errors = @page.errors.collect(&:text)
      expect(errors).to include("Roles must be selected")
      # Verify
      u = User.find(user.id)
    end

    it 'cancels' do
      @form.name.set('Edited Name 3')
      @form.email.set('fake2@email.com')
      @form.click_role('Host')
      @form.actions.cancel.click

      # Verify no changes have been made
      u = User.find(user.id)
      expect(u.name).to eq('User 1')
      expect(u.email).to eq('email@test.com')
      expect(u.requires_auth).to eq(false)
      expect(u.role_titles).to eq([:admin])

      expect(page.current_url).to end_with("/users")
    end

    it 'deletes the user' do
      accept_confirm("This will remove the user from the system\nThis cannot be undone!") do
        @page.delete_button.click
      end
      wait_for_angular_requests_to_finish

      expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(page.current_url).to end_with("/users")
    end

    it 'cancels the delete request' do
      dismiss_confirm("This will remove the user from the system\nThis cannot be undone!") do
        @page.delete_button.click
      end

      expect(User.find(user.id)).to eq(user)
      expect(page.current_url).to end_with("/#/users/#{user.id}/edit")
    end
  end

  describe 'With no roles initially' do
    let(:user) { create_user(role_titles: []) }
    let(:preload) { user }

    before do
      preload if defined?(preload)
      sign_in_admin
      @page = UsersEditPage.new
      @page.load(user_id: user.id)
      wait_for_angular_requests_to_finish
      @form = @page.form
    end

    it_behaves_like 'admin menu' do
      let(:menu) { @page.menu }
      let(:active) { 'Users' }
    end

    it 'validation' do
      @form.actions.submit.click
      wait_for_angular_requests_to_finish

      errors = @page.errors.collect(&:text)
      expect(errors).to include("Roles must be selected")
    end
  end

  # TID-101
  describe 'Edit own user' do
    before do
      preload if defined?(preload)
      admin = create(:user, role_titles: [:admin])
      sign_in(admin)
      @page = UsersEditPage.new
      @page.load(user_id: admin.id)
      wait_for_angular_requests_to_finish
    end

    it_behaves_like "unauthorized"
  end
end

describe 'Admin User (requires auth): /#/users/:user_id/edit', js: true, type: :feature do
  let(:current_user) { create_user(role_titles: [:admin], requires_auth: true) }
  let(:user) { create_user() }
  before do
    sign_in(current_user)
    @page = UsersEditPage.new
    @page.load(user_id: user.id)
    sleep 1
    wait_for_angular_requests_to_finish
  end

  it_behaves_like "requires_auth"
end

describe 'Host User: /#/users/:user_id/edit', js: true, type: :feature do
  let(:host) { create_user(role_titles: [:host]) }
  let(:preload) { host }

  before do
    preload if defined?(preload)
    sign_in(host)
    @page = UsersEditPage.new
    @page.load(user_id: host.id)
    wait_for_angular_requests_to_finish
  end

  skip 'TODO: Fix this when TID-102 is done' do
    it_behaves_like 'host menu' do
      let(:menu) { @page.menu }
    end
  end

  it_behaves_like "unauthorized"
end

describe 'Not Logged In: /#/users/:users_id/edit', js: true, type: :feature do
  before do
    preload if defined?(preload)
    @page = UsersEditPage.new
    @page.load(user_id: 1)
    wait_for_angular_requests_to_finish
  end

  it_behaves_like 'guest menu' do
    let(:menu) { @page.menu }
  end

  it_behaves_like "guest_access"
end
