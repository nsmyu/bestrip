class PendingInvitation < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user, optional: true

  validates :invitation_code, length: { is: 22 }, allow_blank: true
  validates :user, uniqueness: { scope: :itinerary }
  validates :invitation_code, uniqueness: { scope: :itinerary }
  validate :either_or_both_of_user_and_invitation_code_must_be_present

  private

  def either_or_both_of_user_and_invitation_code_must_be_present
    if !(user || invitation_code)
      errors.add(:user, :blank)
      errors.add(:invitation_code, :blank)
    end
  end
end
