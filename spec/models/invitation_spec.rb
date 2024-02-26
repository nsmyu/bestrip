require 'rails_helper'

RSpec.describe Invitation, type: :model, focus: true do
  describe "バリデーション" do
    it "itinerary_idとcodeがあれば有効であること" do
      expect(build(:invitation)).to be_valid
    end

    it "itinerary_idがなければ無効であること" do
      invitations = build(:invitation, itinerary: nil)
      invitations.valid?
      expect(invitations.errors).to be_of_kind(:itinerary, :blank)
    end

    it "codeがなければ無効であること" do
      invitations = build(:invitation, code: nil)
      invitations.valid?
      expect(invitations.errors).to be_of_kind(:code, :wrong_length)
    end

    it "codeが21文字以下の場合は無効であること" do
      invitations = build(:invitation, code: "a" * 21)
      invitations.valid?
      expect(invitations.errors).to be_of_kind(:code, :wrong_length)
    end

    it "codeが23文字以上の場合は無効であること" do
      invitations = build(:invitation, code: "a" * 23)
      invitations.valid?
      expect(invitations.errors).to be_of_kind(:code, :wrong_length)
    end

    it "codeが重複している場合は無効であること" do
      invitation = create(:invitation)
      new_invitation = build(:invitation, code: invitation.code)
      new_invitation.valid?
      expect(new_invitation.errors).to be_of_kind(:code, :taken)
    end

    it "itinerary_idとuser_idの組み合わせが一意でない場合、無効であること" do
      itinerary = create(:itinerary)
      user = create(:user)
      create(:invitation, user: user, itinerary: itinerary)
      invitation = build(:invitation, user: user, itinerary: itinerary)
      invitation.valid?
      expect(invitation.errors).to be_of_kind(:user, :taken)
    end
  end
end
