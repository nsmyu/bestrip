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
      query_params = GooglePlacesApi::Request.new(favorite.place_id)
      result = query_params.request

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
    get_place_details(@place_id)
  end

  def create
    @favorite = @itinerary.favorites.new(favorite_params)
    @place_id = @favorite.place_id
    @favorite.save
  end

  def destroy
    Favorite.find(params[:id]).destroy
    redirect_to :itinerary_favorites, notice: "行きたい場所リストから削除しました。"
  end

  private

  def favorite_params
    params.require(:favorite).permit(:place_id)
  end
end
