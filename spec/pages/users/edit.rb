class UsersEditPage < SitePrism::Page
  set_url "/app#/users/{user_id}/edit"

  element :delete_button, ".sidebar button.delete"

  elements :errors, "div[notices='notices'] .alert"

  section :form, ".main .panel" do
    element :name, "input[name='name']"
    element :email, "input[name='email']"
    element :requires_auth, "input[name='requires_auth']"
    element :role_titles, "select[name='role_titles']"

    section :role_title_sec, ".bootstrap-select" do
      element :select_button, "button[type='button']"
      element :dropdown, "div.dropdown-menu"
    end

    section :actions, ".actions" do
      element :cancel, "button[title='Cancel']"
      element :submit, "button[type='submit']"
    end

    def select_role(role)
      role_title_sec.select_button.click
      role_title_sec.dropdown.find('span', text: role).click
      find('body').click # Clears the dropdown
    end
  end
end
