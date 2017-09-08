class ShowsIndexPage < SitePrism::Page
  set_url "/app#/shows/index"

  elements :notices, "div[notices='notices'] .alert-success"

  element :shows, "#shows"
  element :create_show, ".create-show"

  sections :rows, "#shows tbody tr" do
    element :show_id, ".id"
    element :title, ".title"
    element :air_date, ".air-date"
    element :video_count, ".video-count"

    section :sec_actions, ".actions" do
      element :edit, ".edit"
      element :videos, "a.videos"
    end
  end

  def find_show(show)
    rows.find{|row| row.show_id.text == show.id.to_s }
  end
end

class ShowsForm < SitePrism::Section
  element :title, ".show-title"
  element :air_date, ".show-air-date"
  element :show_hosts, ".show-hosts"
  element :available_hosts, ".available-hosts"
  element :submit, "button[type='submit']"

  sections :sec_show_hosts, UserInfoSection, ".show-hosts user-info"
  sections :sec_available_hosts, UserInfoSection, ".show-available-hosts user-info"

  def find_host(user, section = :sec_show_hosts)
    self.send(section).find{|h| h.user_id.text == user.id.to_s}
  end
end

class ShowsFormPage < SitePrism::Page
  elements :errors, "div[notices='notices'] .alert-danger"

  section :form, ShowsForm, '.main .show-form'
  section :sec_air_date, DatePickerSection, "#ui-datepicker-div"
end

class ShowsNewPage < ShowsFormPage
  set_url "/app#/shows/new"
end

class ShowsEditPage < ShowsFormPage
  set_url "/app#/shows/{user_id}/edit"
end
