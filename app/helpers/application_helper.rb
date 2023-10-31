module ApplicationHelper
  def member_names(itinerary)
    sorted_members = itinerary.members.order("itinerary_users.created_at")
    sorted_members.map { |i| i.name }.join(", ")
  end

  def date_posted(post)
    "#{post.created_at.year}.#{post.created_at.month}.#{post.created_at.day}"
  end

  def itinerary_page?
    request.fullpath.include?('itineraries') && !request.fullpath.end_with?('itineraries')
  end

  def user_page?
    request.fullpath.include?('users/edit')
  end
end
