class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary

  def create
    invitation = @itinerary.create_invitation(nil)
    @invitation_code = invitation.code
  end

  def destroy
    Invitation.find(params[:id]).destroy
    redirect_to :itineraries, notice: "「#{@itinerary.title}」への招待を削除しました。"
  end
end
