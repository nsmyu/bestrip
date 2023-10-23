class PlacesController < ApplicationController
  before_action :authenticate_user!

  def find_places
  end

  def find_destinations
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  end
end
