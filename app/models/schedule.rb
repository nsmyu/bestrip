class Schedule < ApplicationRecord
  belongs_to :itinerary

  validates :title, presence: true, length: { maximum: 50 }
  validates :note, length: { maximum: 500 }
  ICON_VALUES = [
    "", "restaurant", "local_cafe", "hotel", "castle", "attractions",
    "shopping_cart", "landscape", "local_activity", "train", "directions_car",
    "directions_bus", "flight", "directions_walk", "directions_bike",
  ].freeze
  validates :icon, inclusion: { in: ICON_VALUES }
  validate :schedule_date_must_be_between_departure_date_and_return_date

  def schedule_date_must_be_between_departure_date_and_return_date
    return if !schedule_date
    if (schedule_date < itinerary.departure_date) || (itinerary.return_date < schedule_date)
      errors.add(:schedule_date, "出発日〜帰宅日の間で選択してください")
    end
  end
end
