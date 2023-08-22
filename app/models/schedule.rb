class Schedule < ApplicationRecord
  belongs_to :itinerary

  validates :title, presence: true, length: { maximum: 50 }
  validate :schedule_date_must_be_between_departure_date_and_return_date

  def schedule_date_must_be_between_departure_date_and_return_date
    return if !schedule_date
    if (schedule_date < itinerary.departure_date) || (itinerary.return_date < schedule_date)
      errors.add(:schedule_date, "出発日〜帰宅日の間で選択してください")
    end
  end

  mount_uploader :image, ScheduleImageUploader
end
