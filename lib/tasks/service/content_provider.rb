class ContentProvider
  def self.get_subject
    subject = load_content('subject.txt') % [get_matching_date]
    return encode(subject)
  end

  def self.get_content
    content = load_content('content.txt') % [get_matching_date]
    return encode(content)
  end

  private
  def self.get_matching_date
    today = Date.today
    current_weekday = today.wday

    if [0, 1, 2, 3].include?(current_weekday)
      target_date = this_week_wednesday(today)
    else
      target_date = next_week_wednesday(today)
    end

    formatted_date = I18n.l(target_date, format: :short)
    formatted_date
  end

  def self.this_week_wednesday(date)
    days_until_wednesday = 3 - date.wday
    date + days_until_wednesday
  end

  def self.next_week_wednesday(date)
    days_until_sunday = 7 - date.wday
    date + days_until_sunday + 3
  end

  def self.load_content(file_name)
    return File.read("./lib/tasks/resources/#{file_name}")
  end

  def self.encode(text)
    return URI.encode_www_form_component(text)
  end
end