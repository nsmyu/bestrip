module PostsHelper
  HASHTAG_REGEX = /(\s|　|^)\K#.+?(?=(　|\s|$))/

  def link_to_hashtag(content)
    content.gsub(HASHTAG_REGEX) do |hashtag|
      link_to(hashtag, search_posts_path(keyword: hashtag), class: "me-2 text-info")
    end
  end

  def date_posted(post)
    "#{post.created_at.year}.#{post.created_at.month}.#{post.created_at.day}"
  end
end
