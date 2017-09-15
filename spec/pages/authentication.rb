class AuthPage < SitePrism::Page
  set_url "/users/sign_in"
  section :menu, MenuSection, "nav"

  element :sign_in, "#login a"
end
