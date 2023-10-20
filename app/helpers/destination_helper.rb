module DestinationHelper
  def destinations_include?(itinerary, place_id)
    Destination.where(itinerary_id: itinerary.id).where(place_id: place_id).present?
  end
end
