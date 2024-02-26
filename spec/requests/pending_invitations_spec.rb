require 'rails_helper'

RSpec.describe "Invitations", type: :request do
  let(:owner) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: owner) }
  let(:invitee) { create(:user) }

  describe "POST #create" do
    it "成功すること（LINEでの招待時）" do
      sign_in owner
      post itinerary_pending_invitations_path(itinerary_id: itinerary.id)
      expect(itinerary.reload.pending_invitations.count).to eq 1
    end
  end

  describe "DELETE #destroy" do
    before do
      sign_in invitee
    end

    it "メールでの招待（=user_idがある）の削除に成功すること" do
      pending_invitation = create(:pending_invitation, user: invitee, itinerary: itinerary)
      delete itinerary_pending_invitation_path(id: pending_invitation.id,
                                               itinerary_id: itinerary.id)
      expect(response).to redirect_to itineraries_path
    end

    it "LINEでの招待（=invitation_codeがある）の削除に成功すること" do
      pending_invitation = create(:pending_invitation, with_invitation_code, itinerary: itinerary)
      delete itinerary_pending_invitation_path(id: pending_invitation.id,
                                               itinerary_id: itinerary.id)
      expect(response).to redirect_to itineraries_path
    end
  end
end
