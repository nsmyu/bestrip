class FavoritesController < ApplicationController
  include GooglePlacesApi

  before_action -> {
    authenticate_user!
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }

  def index
    return if @itinerary.favorites.blank?
    @place_details_list = []
    @itinerary.favorites.each do |favorite|
      get_details = GooglePlacesApi::Request.new(favorite.place_id)
      result = get_details.request

      case result
      when Hash
        if result[:error_message].blank?
          @place_details_list << GooglePlacesApi::Request
            .attributes_for(result)
            .merge(place_id: favorite.place_id)
        else
          @place_details_list << { error: "スポット情報を取得できませんでした（#{result[:error_message]})" }
        end
      else
        flash.now[:alert] = "スポット情報を取得できませんでした（#{result})"
      end
    end
  end

  def new
    @favorite = @itinerary.favorites.new
    @place_id = params[:place_id]
    get_details = GooglePlacesApi::Request.new(@place_id)
    result = get_details.request

    case result
    when Hash
      if result[:error_message].blank?
        @place_details = GooglePlacesApi::Request.attributes_for(result).merge(place_id: @place_id)
        set_photo_urls(@place_details[:photos]) if @place_details[:photos]
      else
        @error = "スポット情報を取得できませんでした（#{result[:error_message]})"
      end
    else
      @error = "スポット情報を取得できませんでした（#{result})"
    end
  end

  def create
    favorite = @itinerary.favorites.new(favorite_params)
    favorite.save
  end

  def destroy
  end

  private

  def favorite_params
    params.require(:favorite).permit(:place_id)
  end

  def set_photo_urls(place_photos)
    photo_references =  place_photos.pluck(:photo_reference)
    @place_photo_urls = photo_references.map do |photo_reference|
      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_reference}&key=#{ENV['GOOGLE_API_KEY']}"
    end
  end
end
