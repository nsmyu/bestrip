class Destination < ApplicationRecord
  belongs_to :itinerary

  validates :place_id, presence: true, uniqueness: { scope: :itinerary_id }
  validate :destinations_per_itinerary_cannot_be_more_than_three_hundreds

  def destinations_per_itinerary_cannot_be_more_than_three_hundreds
    if itinerary && itinerary.destinations.count >= 300
      errors.add(:itinerary_id, "このプランの行きたい場所は上限の300件まで登録されているため、追加できません")
    end
  end
end
