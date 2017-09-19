class MenuSection < SitePrism::Section
  element :home, "#home_nav a"
  element :users, "#users_nav li a"
  element :shows, "#shows_nav li a"
  element :playlists, "#playlists_nav li a"
  element :logout, "#logout_nav li a"
  element :login, "#login_nav li a"

  element :active, "#navbar li.active a"
end
