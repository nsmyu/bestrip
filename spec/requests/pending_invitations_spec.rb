require 'rails_helper'

RSpec.describe "PendingInvitations", type: :request do
  let(:owner) { create(:user) }
  let(:invitee) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: owner) }

  before do
    sign_in invitee
  end

  describe "DELETE #destroy" do
    it "成功すること" do
      pending_invitation = create(:pending_invitation, user: invitee, itinerary: itinerary)
      delete itinerary_pending_invitation_path(id: pending_invitation.id, itinerary_id: itinerary.id)
      expect(response).to redirect_to itineraries_path
    end
  end
end
