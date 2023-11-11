module ItinerariesHelper
  def member_names(itinerary)
    itinerary.members.map { |i| i.name }.join(", ")
  end
end
