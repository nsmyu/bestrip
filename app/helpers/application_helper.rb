module ApplicationHelper
  BASE_TITLE = "BesTrip".freeze

  def full_title(page_title)
    page_title.blank? ? BASE_TITLE : "#{page_title} | #{BASE_TITLE}"
  end
end
