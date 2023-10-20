module FavoritesHelper
  def favorites_include?(place_id)
    Favorite.where(user_id: current_user.id).where(place_id: place_id).present?
  end
end
