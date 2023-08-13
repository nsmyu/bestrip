class Itinerary < ApplicationRecord
  has_many   :itinerary_users, dependent: :destroy
  has_many   :members, through: :itinerary_users, source: :user
  belongs_to :owner, class_name: 'User', foreign_key: :user_id

  validates :title, presence: true, length: { maximum: 30 }, uniqueness: { scope: :user_id }
  validates :departure_date, :return_date, presence: true
  validate :return_date_must_be_after_departure_date

  def return_date_must_be_after_departure_date
    return if !(departure_date && return_date)
    if return_date < departure_date
      errors.add(:return_date, "は出発日以降で選択してください")
    end
  end

  mount_uploader :image, ItineraryImageUploader
end
