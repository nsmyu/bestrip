class PendingInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary

  def create
    @invitation_code = SecureRandom.urlsafe_base64
    @itinerary.pending_invitations.create(code: @invitation_code)
  end

  def destroy
    PendingInvitation.find(params[:id]).destroy
    redirect_to :itineraries, notice: "「#{@itinerary.title}」への招待を削除しました。"
  end
end
