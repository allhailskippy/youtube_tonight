#
# Must define these ahead of time:
# page_pagination: The PaginationSection object being tested
# objects:         The full set of objects to paginate through
# site_page:       The siteprism page object
# results_method:  The method to send the page to get results shown on the page
#
# Example Usage:
#  it_should_behave_like "paginated" do
#    let(:page_pagination) { @page.pagination }
#    let(:objects) { playlists }
#    let(:results_method) { :rows }
#    let(:site_page) { @page }
#  end
#
shared_examples "paginated" do #|page_pagination, objects, results| 
  it "checks default pagination settings " do
    p = page_pagination
    expected = "Page 1 of #{objects.length / 10}, of #{objects.length} entries"
    expect(p.description.text).to eq(expected)
    expect(p.active_per_page.text).to eq("10")
    expect(p.pages.active.text).to eq("1")
    expect(site_page.send(results_method).length).to eq(10)
  end

  it 'changes how many per page are returned' do
    p = page_pagination
    [5, 10, 20, 50].each do |n|
      p.find_per_page(n.to_s).click
      wait_for_angular_requests_to_finish
      expect(site_page.send(results_method).length).to eq(n)
    end
  end

  it 'shows the correct page numbers' do
    p = page_pagination
    range = (0..9)
    range.each do |n|
      start = n <= 2 ? 0 : (n - 2)
      page_num = n + 1
      expected_pages = (range.to_a[start, 5]).map{|x| x += 1}

      # Should typically have 5 + prev + next. Last 2 pages have less
      expected = n < 8 ? 7 : (n < 9 ? 6 : 5)
      expect(p.pages.page_nums.length).to eq(expected)

      expected_pages.each do |pg|
        if pg == page_num
          expect(p.pages.active.text).to eq(page_num.to_s)
        else
          expect(p.find_page(pg.to_s)).to_not be_nil
        end
      end
      if n < range.max
        next_page = (page_num + 1).to_s
        p.find_page(next_page).click
        wait_for_angular_requests_to_finish
      end
    end
  end

  it 'can scroll through the pages if available' do
    p = page_pagination
    p.find_per_page("5").click
    wait_for_angular_requests_to_finish

    range = (0..19)
    max_to_check = range.max - 2
    min_to_check = 3
    range.each do |n|
      start = n <= 2 ? 0 : (n - 2)
      expected_pages = (range.to_a[start, 5])
      if expected_pages.last < range.max
        # Check that it can scroll all the way to the end
        while start + 4 < range.max
          start = expected_pages.last + 1
          expected_pages = (start..start + 4)
          if expected_pages.max <= range.max
            p.pages.next.click
          end
        end

        # Scroll back to beginning
        while start > 0
          if expected_pages.min > 0
            p.pages.previous.click
          end
          start -= 5
          start = 0 if start < 0
          expected_pages = (start..start+4)
        end

        expect(p.pages.previous_disabled).to_not be_nil

        # And then back up until the current page
        while !expected_pages.include?(n)
          start = expected_pages.last + 1
          expected_pages = (start..start + 4)
          p.pages.next.click
        end

        # If the current page is the last one showing,
        # we need to hit the 'next' button once more
        if n == expected_pages.max
          p.pages.next.click
        end
      else
        expect(p.pages.next_disabled).to_not be_nil
      end
      if n < range.max
        page_num = n + 1
        next_page = (page_num + 1).to_s
        p.find_page(next_page).click
        wait_for_angular_requests_to_finish
      end
    end
  end

  it 'has the correct description' do
    p = page_pagination
    range = (0..9)
    range.each do |n|
      page_num = n + 1

      expected = "Page #{page_num} of #{range.max + 1}, of #{objects.length} entries"
      expect(p.description.text).to eq(expected)

      if n < range.max
        next_page = (page_num + 1).to_s
        p.find_page(next_page).click
        wait_for_angular_requests_to_finish
      end
    end
  end
end
