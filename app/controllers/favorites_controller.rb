class FavoritesController < ApplicationController
  before_action -> {
    authenticate_user!
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }

  def index

  end

  def create

  end

  def destroy

  end
end
