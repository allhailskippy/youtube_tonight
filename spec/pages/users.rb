class UsersIndexPage < SitePrism::Page
  set_url "/#/users"
  section :menu, MenuSection, "nav"

  element :users, "#users"

  sections :user_rows, "#users tbody tr" do
    element :user_id, ".user-id"
    element :profile_image, ".profile img"
    element :name, ".user-name"
    element :email, ".user-email"
    element :roles, ".user-roles"

    section :sec_actions, ".actions" do
      element :authorize, "span[title='Authorize']"
      element :deauthorize, "span[title='De-Authorize']"
      element :edit, "span[title='Edit User']"
      element :videos, "a.videos"
    end
  end

  def find_row(user)
    user_rows.find{|ur| ur.user_id.text == user.id.to_s }
  end
end

class UsersEditPage < SitePrism::Page
  set_url "/#/users/{user_id}/edit"
  section :menu, MenuSection, "nav"

  element :delete_button, ".sidebar button.delete"

  elements :errors, "div[notices='notices'] .alert-danger"

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
      element :cancel, "#cancel"
      element :submit, "button[type='submit']"
    end

    def select_role(role)
      role_title_sec.select_button.click
      role_title_sec.dropdown.find('span', text: role).click
      find('body').click # Clears the dropdown
    end
  end
end
