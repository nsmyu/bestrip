module ApplicationHelper
  BASE_TITLE = "BesTrip".freeze

  def full_title(page_title)
    page_title.blank? ? BASE_TITLE : "#{page_title} | #{BASE_TITLE}"
  end

  def ogp_meta_tags(page_title)
    ogp_meta_tags = {}
    if controller_name == "sessions" && action_name == "new" && @invitation_code
      ogp_meta_tags[:title] = @itinerary.title
      ogp_meta_tags[:description] = "#{ l @itinerary.departure_date } 〜 #{ l @itinerary.return_date }"
      ogp_meta_tags[:image] = "https://s3.ap-northeast-1.amazonaws.com/bestrip#{@itinerary.image.url}"
    else
      ogp_meta_tags[:title] = full_title(page_title)
      ogp_meta_tags[:description] = "BesTripは、簡単に旅のプランを作成できるアプリです。メンバーと共同でスケジュールを編集したり、みんなの思い出投稿から素敵なスポットを発見したり。楽しく計画を立てて、Bestな旅に出かけましょう。"
      ogp_meta_tags[:image] = "https://bestrip.s3.ap-northeast-1.amazonaws.com/uploads/default_ogp_image.png"
    end
    ogp_meta_tags
  end
end




