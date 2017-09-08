class ShowsIndexPage < SitePrism::Page
  set_url "/app#/shows/index"

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

  def find_row(show)
    rows.find{|row| row.show_id.text == show.id.to_s }
  end
end
