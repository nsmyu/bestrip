module ApplicationHelper
  def member_names(itinerary)
    sorted_members = itinerary.members.order("itinerary_users.created_at")
    sorted_members.map { |i| i.name }.join(", ")
  end
end
