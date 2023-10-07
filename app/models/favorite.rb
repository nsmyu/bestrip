class Favorite < ApplicationRecord
  belongs_to :itinerary

  validates :place_id, presence: true, uniqueness: { scope: :itinerary_id }
  validate :favorites_per_itinerary_cannot_be_more_than_three_hundreds

  def favorites_per_itinerary_cannot_be_more_than_three_hundreds
    if itinerary && itinerary.favorites.count >= 300
      errors.add(:itinerary_id, "ひとつの旅のプランにつき、行きたい場所リストへの登録は300件までです")
    end
  end
end
