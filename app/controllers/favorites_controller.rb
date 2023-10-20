class FavoritesController < ApplicationController
  include GooglePlacesApi

  before_action :authenticate_user!

  def index
    return if current_user.favorites.blank?
    @place_details_list = []
    current_user.favorites.each do |favorite|
      query_params = GooglePlacesApi::Request.new(favorite.place_id)
      result = query_params.request

      case result
      when Hash
        if result[:error_message].blank?
          place_details = GooglePlacesApi::Request.attributes_for(result)
          place_details[:favorite_id] = favorite.id
          if place_details[:photos]
            set_photo_urls(place_details[:photos])
            place_details[:photo_url] = @place_photo_urls[0]
          else
            place_details[:photo_url] = "default_place.png"
          end
          @place_details_list << place_details
        else
          @place_details_list << {
            error: "スポット情報を取得できませんでした（#{result[:error_message]})",
            photo_url: "default_place.png",
          }
        end
      else
        flash.now[:notice] = "スポット情報を取得できませんでした（#{result})"
      end
    end
  end

  def new
    @favorite = current_user.favorites.new
    @place_id = params[:place_id]
    get_place_details(@place_id)
  end

  def create
    @favorite = current_user.favorites.new(favorite_params)
    @place_id = @favorite.place_id
    @favorite.save
  end

  def show
    favorite = Favorite.find(params[:id])
    get_place_details(favorite.place_id)
  end

  def destroy
    Favorite.find(params[:id]).destroy
    redirect_to :favorites, notice: "行きたい場所リストから削除しました。"
  end

  private

  def favorite_params
    params.require(:favorite).permit(:place_id)
  end
end
