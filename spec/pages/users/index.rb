class UsersIndexPage < SitePrism::Page
  set_url "/app#/users/index"

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
