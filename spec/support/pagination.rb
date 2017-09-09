class PaginationSection < SitePrism::Section
  elements :per_page, "button"
  element :active_per_page, "button.active"
  element :description, ".row > div:nth-child(3)"

  section :pages, ".pagination" do
    element :active, "li.active span:first-child"
    element :previous_disabled, "li:first-of-type.disabled"
    element :previous, "li:first-of-type a"
    element :next_disabled, "li:last-of-type.disabled"
    element :next, "li:last-of-type a"
    elements :page_nums, "li a"
  end

  def find_page(page_num)
    pages.page_nums.find{|page| page.text == page_num }
  end

  def find_per_page(value)
    per_page.find{|pp| pp.text == value}
  end
end
