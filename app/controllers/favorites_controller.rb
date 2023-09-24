class FavoritesController < ApplicationController
  include GoogleApiConnectable

  before_action -> {
    authenticate_user!
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }

  def index
  end

  def new
    @favorite = @itinerary.favorites.new
    @place_id = params[:place_id]
    get_place_details(@place_id)
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
end
