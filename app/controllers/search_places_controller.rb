class SearchPlacesController < ApplicationController
  before_action -> {
    authenticate_user!
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }
end
