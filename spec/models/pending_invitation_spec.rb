require 'rails_helper'

RSpec.describe PendingInvitation, type: :model do
  describe "バリデーション" do
    it "itinerary_idとuser_idがあれば有効であること" do
      expect(build(:pending_invitation, :with_user_id)).to be_valid
    end

    it "itinerary_idとuser_idの組み合わせが一意でない場合、無効であること" do
      itinerary = create(:itinerary)
      user = create(:user)
      create(:pending_invitation, user: user, itinerary: itinerary)
      pending_invitation = build(:pending_invitation, user: user, itinerary: itinerary)
      pending_invitation.valid?
      expect(pending_invitation.errors).to be_of_kind(:user, :taken)
    end

    it "itinerary_idとinvitation_codeがあれば有効であること" do
      expect(build(:pending_invitation, :with_invitation_code)).to be_valid
    end

    it "itinerary_idとinvitation_codeの組み合わせが一意でない場合、無効であること" do
      itinerary = create(:itinerary)
      existing_invitation = create(:pending_invitation, :with_invitation_code, itinerary: itinerary)
      pending_invitation = build(:pending_invitation, itinerary: itinerary, invitation_code: existing_invitation.invitation_code)
      pending_invitation.valid?
      expect(pending_invitation.errors).to be_of_kind(:invitation_code, :taken)
    end

    it "itinerary_idがなければ無効であること" do
      pending_invitations = build(:pending_invitation, :with_user_id, :with_invitation_code, itinerary: nil)
      pending_invitations.valid?
      expect(pending_invitations.errors).to be_of_kind(:itinerary, :blank)
    end

    it "user_idもinvitation_codeも無い場合は無効であること" do
      pending_invitations = build(:pending_invitation)
      pending_invitations.valid?
      expect(pending_invitations.errors).to be_of_kind(:user, :blank)
      expect(pending_invitations.errors).to be_of_kind(:invitation_code, :blank)
    end
  end
end
