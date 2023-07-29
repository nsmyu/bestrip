class Itinerary < ApplicationRecord
  belongs_to :owner, class_name: User, foreign_key: :user_id

  validates :name,           presence: true, length: { maximum: 50 }
  validates :departure_date, presence: true
  validates :return_date,    presence: true
  validate :return_date_must_be_after_departure_date

  def return_date_must_be_after_departure_date
    if departure_date == nil || return_date == nil
      return
    elsif return_date <= departure_date
      errors.add(:check_out_on, "は帰宅日の翌日以降で選択してください")
    end
  end
end

