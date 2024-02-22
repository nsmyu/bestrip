class ItineraryUser < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user

  validates :user, uniqueness: { scope: :itinerary }
end
