module ApplicationHelper
  BASE_TITLE = "BesTrip".freeze

  def full_title(page_title)
    page_title.blank? ? BASE_TITLE : "#{page_title} | #{BASE_TITLE}"
  end

  def ogp_image(itinerary_image_url)
    if itinerary_image_url == "default_itinerary.jpg"
      "https://bestrip.s3.ap-northeast-1.amazonaws.com/uploads/default_ogp_image.png"
    else
      "#{itinerary_image_url}"
    end
  end
end
