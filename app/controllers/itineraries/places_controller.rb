class Itineraries::PlacesController < PlacesController
  before_action :authenticate_user!
  before_action -> {
    set_placeable
    authenticate_itinerary_member(@placeable)
  }, except: %i(show select_itinerary)

  def destroy
    super
    if request.referer&.end_with?("/places") && @placeable.places.count.zero?
      redirect_to [:itinerary_places, itinerary_id: @placeable.id], notice: "スポットを削除しました。"
    end
  end

  # 　下記二つのアクションは、「お気に入り（:users_places)」から旅のプランを選択し、
  # 選択した旅のプランの「スポットリスト（:itinerary_places）」に追加する際に使用
  def select_itinerary
    @itineraries = current_user.itineraries.order(departure_date: :desc)
    @itinerary = @itineraries[0]
    @place = Place.new
    @place_id = params[:place_id]
  end

  def add_from_user_places
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
