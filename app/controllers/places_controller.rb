class PlacesController < ApplicationController
  include GooglePlacesApiRequestable

  before_action :authenticate_user!

  def index
    return if @placeable.places.blank?
  end

  def index_lazy
    @place_index_items = @placeable.places.order(created_at: :desc).page(params[:page]).per(10)

    @place_index_items.each do |place_index_item|
      query_params = GooglePlacesApiRequestable::Request.new(place_index_item.place_id)
      response = query_params.request

      case response
      when Hash
        if response[:error_message].blank?
          place_details = attributes_for(response)

          if place_details[:photos]
            set_photo_urls(place_details[:photos])
            place_index_item.photo_url = @place_photo_urls[0]
          else
            place_index_item.photo_url = "default_place.png"
          end

          place_details.delete(:photos)
          place_details.each do |attr, value|
            place_index_item.send("#{attr}=", value)
          end
        else
          place_index_item.photo_url = "default_place.png"
          place_index_item.error = "スポット情報を取得できませんでした（#{response[:error_message]})"
        end
      else
        flash.now[:notice] = "スポット情報を取得できませんでした（#{response})"
      end
    end
  end

  def find
  end

  def new
    @place_id = params[:place_id]
    get_place_details(@place_id)

    @place =
      Place
        .where(placeable_type: @placeable.class.to_s)
        .where(placeable_id: @placeable.id)
        .find_by(place_id: @place_id) ||
      @placeable.places.new
  end

  def create
    @place = @placeable.places.new(place_params)
    @place.save
    @place_id = @place.place_id
  end

  def show
    place = Place.find(params[:id])
    get_place_details(place.place_id)
  end

  def destroy
    @place_id = Place.find(params[:id]).place_id
    @place = @placeable.places.new
    @place_index_item = Place.find(params[:id])
    @place_index_item.destroy

    if request.referer&.end_with?("/places") && @placeable.places.count.zero?
      redirect_to @placeable.user? ? :users_places : [:itinerary_places, itinerary_id: @placeable.id]
    end
  end

  private

  def place_params
    params.require(:place).permit(:place_id)
  end
end
