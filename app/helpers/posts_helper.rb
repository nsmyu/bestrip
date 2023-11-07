module PostsHelper
  HASHTAG_REGEX = /(\s|　|^)\K#.+?(?=(　|\s|$))/.freeze

  def link_to_hashtag(content)
    content.gsub(HASHTAG_REGEX) { |hashtag| link_to(hashtag, search_posts_path(keyword: hashtag), class:"me-2 text-info") }
  end
end
