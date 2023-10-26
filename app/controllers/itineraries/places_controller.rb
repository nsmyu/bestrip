class Itineraries::PlacesController < PlacesController
  before_action -> {
    set_placeable
    authenticate_itinerary_member(@placeable)
  }, except: :select_itinerary

  # 　下記二つのアクションは、「お気に入り（:users_places)」から旅のプランを選択し、
  # 選択した旅のプランの「スポットリスト（:itinerary_places）」に追加する際に使用
  def select_itinerary
    @itineraries = current_user.itineraries.order(departure_date: :desc)
    @itinerary = @itineraries[0]
    @place = Place.new
    @place_id = params[:place_id]
  end

  def from_user_to_itinerary
    @itineraries = current_user.itineraries.order(departure_date: :desc)
    @place = @placeable.places.new(place_params)
    @place.save
  end

  private

  def set_placeable
    @placeable = Itinerary.find(params[:itinerary_id])
    @itinerary = @placeable
  end
end
