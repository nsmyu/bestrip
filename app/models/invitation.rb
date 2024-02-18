class Invitation < ApplicationRecord
  belongs_to :invited_to_itinerary, class_name: 'Itinerary', foreign_key: :itinerary_id
  belongs_to :invitee, class_name: 'User', foreign_key: :user_id

  validates :invitee, uniqueness: { scope: :invited_to_itinerary }
  validate :existing_member_cannot_be_invited_to_itinerary

  def existing_member_cannot_be_invited_to_itinerary
    return if !(invited_to_itinerary && invitee)
    if invited_to_itinerary.members.includes([:user]).include? invitee
      errors.add(:invitee, "#{invitee.name}さんはすでにメンバーに含まれています")
    end
  end
end
