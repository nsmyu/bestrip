class Itinerary < ApplicationRecord
  include Placeable

  belongs_to :owner, class_name: 'User', foreign_key: :user_id
  has_many   :itinerary_users, dependent: :destroy
  has_many   :members, through: :itinerary_users, source: :user
  has_many   :invitations, dependent: :destroy
  has_many   :invitees, through: :invitations, source: :user
  has_many   :schedules, dependent: :destroy
  has_many   :posts, dependent: :destroy

  validates :title, presence: true, length: { maximum: 30 }
  validates :departure_date, :return_date, presence: true
  validate :return_date_must_be_after_departure_date

  after_commit :add_owner_to_members, on: :create

  mount_uploader :image, ItineraryImageUploader

  scope :contains_keyword, -> (keyword) do
    joins(:schedules).merge(Schedule.where("schedules.title LIKE?", "%#{keyword}%"))
  end

  private

  def add_owner_to_members
    members << owner
  end

  def return_date_must_be_after_departure_date
    return if !(departure_date && return_date)
    if return_date < departure_date
      errors.add(:return_date, "は出発日以降で選択してください")
    end
  end
end
