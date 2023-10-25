class PlacesController < ApplicationController
  include GooglePlacesApiRequestable

  before_action :authenticate_user!

  def index
    @placeable = User.find(params[:user_id])
    return if @placeable.places.blank?
  end

  def index_lazy
    @placeable = User.find(params[:user_id])
    @places = @placeable.places.order(created_at: :desc)
    @paginatable_places = Kaminari.paginate_array(@places).page(params[:page]).per(10)
    @place_details_list = []

    @paginatable_places.each do |place|
      query_params = GooglePlacesApiRequestable::Request.new(place.place_id)
      result = query_params.request

      case result
      when Hash
        if result[:error_message].blank?
          place_details = attributes_for(result)
          place_details[:temp_id] = place.id

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
    @placeable = User.find(params[:user_id])
    @place_id = params[:place_id]
    get_place_details(@place_id)

    if Place.where(placeable_type: @placeable.class.to_s).where(placeable_id: @placeable.id).find_by(place_id: @place_id)
      @place = Place.where(placeable_type: @placeable.class.to_s).where(placeable_id: @placeable.id).find_by(place_id: @place_id)
    else
      @place = @placeable.places.new
    end
  end

  def create
    @placeable = User.find(params[:user_id])
    @place = @placeable.places.new(place_params)
    @place_id = @place.place_id
    @place.save
  end

  def show
    place = Place.find(params[:id])
    get_place_details(place.place_id)
  end

  def destroy
    @placeable = User.find(params[:user_id])
    @place = @placeable.places.new
    @place_id = Place.find(params[:id]).place_id
    Place.find(params[:id]).destroy

    if request.referer&.end_with? "/places"
      redirect_to :user_places, notice: "お気に入りから削除しました。"
    end
  end

  private

  def set_placeable
    @placeable = User.find(params[:user_id])
  end

  def place_params
    params.require(:place).permit(:place_id)
  end




















  def find_places
  end

  def find_destinations
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  end
end
