module PostsHelper
  HASHTAG_REGEX = /(\s|　|^)\K#.+?(?=(　|\s|$))/

  def link_to_hashtag(text)
    text.gsub(HASHTAG_REGEX) do |hashtag|
      link_to(hashtag, search_posts_path(keyword: hashtag), class: "me-2 text-info")
    end
  end
end
