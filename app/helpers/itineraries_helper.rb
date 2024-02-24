module ItinerariesHelper
  def member_names(itinerary)
    itinerary.members.map { |member| member.name }.join(", ")
  end
end
