require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe "バリデーション" do
    it "user_id、itinerary_idがあれば有効であること" do
      expect(build(:invitation)).to be_valid
    end

    it "user_id(invitee)がなければ無効であること" do
      invitation = build(:invitation, invitee: nil)
      invitation.valid?
      expect(invitation.errors).to be_of_kind(:invitee, :blank)
    end

    it "itinerary_id(invited_to_itinerary)がなければ無効であること" do
      invitation = build(:invitation, invited_to_itinerary: nil)
      invitation.valid?
      expect(invitation.errors).to be_of_kind(:invited_to_itinerary, :blank)
    end

    it "inviteeとinvited_to_itineraryの組み合わせが一意でない場合、無効であること" do
      invited_to_itinerary = create(:itinerary)
      invitee = create(:user)
      create(:invitation, invitee: invitee, invited_to_itinerary: invited_to_itinerary)
      invitation = build(:invitation, invitee: invitee, invited_to_itinerary: invited_to_itinerary)
      invitation.valid?
      expect(invitation.errors).to be_of_kind(:invitee, :taken)
    end
  end
end
