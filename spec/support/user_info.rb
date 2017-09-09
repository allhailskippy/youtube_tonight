class UserInfoSection < SitePrism::Section
  element :profile_image, '.user-profile-image'
  element :user_id, '.user-id'
  element :name, '.user-name'
  element :email, '.user-email'
end
