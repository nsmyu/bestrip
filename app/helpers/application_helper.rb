module ApplicationHelper
  def member_names(itinerary)
    sorted_members = itinerary.members.order("itinerary_users.created_at")
    sorted_members.map { |i| i.name }.join(", ")
  end

  def short_address(formatted_address)
    formatted_address.sub(/日本、〒\d{3}[-]\d{4}/, '')
  end
end
