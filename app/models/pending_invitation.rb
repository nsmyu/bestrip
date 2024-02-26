class PendingInvitation < ApplicationRecord
  belongs_to :itinerary
  belongs_to :user, optional: true

  validates :user, uniqueness: { scope: :itinerary }, allow_nil: true
  validates :code, length: { is: 22 }, uniqueness: true, allow_blank: true
  validate :either_or_both_of_user_and_code_must_be_present

  private

  def either_or_both_of_user_and_code_must_be_present
    if !(user || code)
      errors.add(:user, :blank)
      errors.add(:code, :blank)
    end
  end
end
