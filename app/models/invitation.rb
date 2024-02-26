class Invitation < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user, optional: true

  validates :user, uniqueness: { scope: :itinerary }, allow_nil: true
  validates :code, length: { is: 22 }, uniqueness: true

  def add_user(user)
    update(user_id: user.id)
  end
end
