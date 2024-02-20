require 'rails_helper'

RSpec.describe PendingInvitation, type: :model do
  describe "バリデーション" do
    it "user_id、itinerary_idがあれば有効であること" do
      expect(build(:pending_invitation)).to be_valid
    end

    it "user_id(invitee)がなければ無効であること" do
      pending_invitation = build(:pending_invitation, invitee: nil)
      pending_invitation.valid?
      expect(pending_invitation.errors).to be_of_kind(:invitee, :blank)
    end

    it "itinerary_id(invited_to_itinerary)がなければ無効であること" do
      pending_invitation = build(:pending_invitation, invited_to_itinerary: nil)
      pending_invitation.valid?
      expect(pending_invitation.errors).to be_of_kind(:invited_to_itinerary, :blank)
    end

    it "inviteeとinvited_to_itineraryの組み合わせが一意でない場合、無効であること" do
      invited_to_itinerary = create(:itinerary)
      invitee = create(:user)
      create(:pending_invitation, invitee: invitee, invited_to_itinerary: invited_to_itinerary)
      pending_invitation = build(:pending_invitation, invitee: invitee,
                                                      invited_to_itinerary: invited_to_itinerary)
      pending_invitation.valid?
      expect(pending_invitation.errors).to be_of_kind(:invitee, :taken)
    end
  end
end
