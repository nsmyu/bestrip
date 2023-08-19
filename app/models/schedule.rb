class Schedule < ApplicationRecord
  belongs_to :itinerary, foreign_key: :itinerary_id
end
