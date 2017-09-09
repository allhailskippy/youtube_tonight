class DatePickerSection < SitePrism::Section
  elements :dates, ".ui-datepicker-calendar td"

  section :header, ".ui-datepicker-header" do
    element :previous, ".ui-datepicker-prev"
    element :next, ".ui-datepicker-next"
    element :month_year, ".ui-datepicker-title"
  end

  def select_date(date)
    date = date.to_date if date.kind_of?(String)

    while(date < header.month_year.text.to_date)
      header.previous.click
    #  shown_date = header.month_year.text.to_date
    end
    while(date > header.month_year.text.to_date.end_of_month)
      header.next.click
    end

    dates.find{|d| date.day.to_s == d.text}.click
  end

  def select_today
    select_date(Date.today)
  end
end
