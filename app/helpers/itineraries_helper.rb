module ItinerariesHelper
  def member_names(itinerary)
    itinerary.confirmed_members.map { |member| member.name }.join(", ")
  end
end
