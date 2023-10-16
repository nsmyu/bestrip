module ApplicationHelper
  def member_names(itinerary)
    sorted_members = itinerary.members.order("itinerary_users.created_at")
    sorted_members.map { |i| i.name }.join(", ")
  end

  def posted_date(post)
    "#{post.created_at.year}.#{post.created_at.month}.#{post.created_at.day}"
  end
end
