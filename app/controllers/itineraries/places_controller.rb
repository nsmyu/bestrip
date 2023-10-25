class Itineraries::PlacesController < PlacesController
  before_action -> {
    set_placeable
    authenticate_itinerary_member(@placeable)
  }, except: :select_itinerary

  def select_itinerary
    @itineraries = current_user.itineraries.order(departure_date: :desc)
    @itinerary = @itineraries[0]
    @place = Place.new
    @place_id = Place.find(params[:temp_id]).place_id
  end

  def create
    super
    @itineraries = current_user.itineraries.order(departure_date: :desc)

    if request.referer&.end_with? "/find_destinations"
      redirect_to find_destinations_itinerary_url(@itinerary), notice: "スポットリストに追加しました。"
    end
  end

  private

  def set_placeable
    @placeable = Itinerary.find(params[:itinerary_id])
    @itinerary = @placeable
  end
end
