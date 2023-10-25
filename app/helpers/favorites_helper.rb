module FavoritesHelper
  def places_include?(placeable, place_id)
    Place.where(placeable_type: placeable.class.to_s).where(placeable_id: placeable.id).where(place_id: place_id).present?
  end
end
