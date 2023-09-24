class Favorite < ApplicationRecord
  belongs_to :itinerary

  validates :place_id, presence: true, uniqueness: { scope: :itinerary_id }
end
