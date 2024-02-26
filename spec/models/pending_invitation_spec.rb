require 'rails_helper'

RSpec.describe PendingInvitation, type: :model do
  describe "バリデーション" do
    it "itinerary_idとuser_idがあれば有効であること" do
      expect(build(:pending_invitation, :with_user)).to be_valid
    end

    it "itinerary_idとuser_idの組み合わせが一意でない場合、無効であること" do
      itinerary = create(:itinerary)
      user = create(:user)
      create(:pending_invitation, user: user, itinerary: itinerary)
      pending_invitation = build(:pending_invitation, user: user, itinerary: itinerary)
      pending_invitation.valid?
      expect(pending_invitation.errors).to be_of_kind(:user, :taken)
    end

    it "itinerary_idとcodeがあれば有効であること" do
      expect(build(:pending_invitation, :with_code)).to be_valid
    end

    it "itinerary_idがなければ無効であること" do
      pending_invitations = build(:pending_invitation, :with_user, :with_code, itinerary: nil)
      pending_invitations.valid?
      expect(pending_invitations.errors).to be_of_kind(:itinerary, :blank)
    end

    it "user_idもcodeも無い場合は無効であること" do
      pending_invitations = build(:pending_invitation)
      pending_invitations.valid?
      expect(pending_invitations.errors).to be_of_kind(:user, :blank)
      expect(pending_invitations.errors).to be_of_kind(:code, :blank)
    end
  end
end
