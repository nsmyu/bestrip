class DestinationsController < ApplicationController
  include GooglePlacesApi

  before_action :authenticate_user!
  before_action -> {
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }, except: :select_itinerary

  def index
    return if @itinerary.destinations.blank?
    @place_details_list = []
    @itinerary.destinations.order(created_at: :desc).each do |destination|
      query_params = GooglePlacesApi::Request.new(destination.place_id)
      result = query_params.request

      case result
      when Hash
        if result[:error_message].blank?
          place_details = GooglePlacesApi::Request.attributes_for(result)
          place_details[:destination_id] = destination.id

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
    @destination = @itinerary.destinations.new
    @place_id = params[:place_id]
    get_place_details(@place_id)

    if Favorite.where(user_id: current_user.id).find_by(place_id: @place_id)
      @favorite = Favorite.where(user_id: current_user.id).find_by(place_id: @place_id)
    else
      @favorite = current_user.favorites.new
    end
  end

  def select_itinerary
    @itineraries = current_user.itineraries.order(departure_date: :desc)
    @itinerary = @itineraries[0]
    @destination = Destination.new
    @place_id = Favorite.find(params[:favorite_id]).place_id
  end

  def create
    @itineraries = current_user.itineraries.order(departure_date: :desc)
    @destination = @itinerary.destinations.new(destination_params)
    @destination.save

    if request.referer&.end_with? "/find_destinations"
      redirect_to find_destinations_itinerary_url(@itinerary), notice: "スポットリストに追加しました。"
    end
  end

  def show
    destination = Destination.find(params[:id])
    get_place_details(destination.place_id)
  end

  def destroy
    Destination.find(params[:id]).destroy
    redirect_to :itinerary_destinations, notice: "スポットリストから削除しました。"
  end

  private

  def destination_params
    params.require(:destination).permit(:place_id)
  end
end
