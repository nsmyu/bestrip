module FavoritesHelper
  def favorites_list_includes?(itinerary, place_id)
    Favorite.where(itinerary_id: itinerary.id).where(place_id: place_id).present?
  end
end
