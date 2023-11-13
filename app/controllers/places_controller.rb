class PlacesController < ApplicationController
  include GooglePlacesApiRequestable

  def index
    return if @placeable.places.blank?
  end

  def index_lazy
    @place_index_items = @placeable.places.order(created_at: :desc).page(params[:page]).per(8)
    @place_index_items.each do |place_index_item|
      query_params =
        GooglePlacesApiRequestable::Request.new(place_index_item.place_id, with_photos: false)
      response = query_params.request

      case response
      when Hash
        if response[:error_message].blank?
          place_details = attributes_for(response)
          place_details.delete(:photos)

          place_details.each do |attr, value|
            place_index_item.send("#{attr}=", value)
          end
        else
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

    if @placeable
      authenticate_user!
      @place =
        Place
          .where(placeable_type: @placeable.class.to_s)
          .where(placeable_id: @placeable.id)
          .find_by(place_id: @place_id) ||
        @placeable.places.new
    end
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
    flash.now[:notice] = "スポットを削除しました。" if request.referer&.end_with?("/places")
  end

  private

  def place_params
    params.require(:place).permit(:place_id)
  end
end
