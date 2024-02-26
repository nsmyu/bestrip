require 'rails_helper'

RSpec.describe "Invitations", type: :request do
  let(:owner) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: owner) }
  let(:invitee) { create(:user) }

  describe "POST #create" do
    it "成功すること（LINEでの招待時）" do
      sign_in owner
      post itinerary_invitations_path(itinerary_id: itinerary.id)
      expect(itinerary.reload.invitations.count).to eq 1
    end
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      invitation = create(:invitation, itinerary: itinerary)
      sign_in invitee
      delete itinerary_invitation_path(id: invitation.id, itinerary_id: itinerary.id)
      expect(response).to redirect_to itineraries_path
    end
  end
end
