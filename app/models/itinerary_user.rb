class ItineraryUser < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user
end
