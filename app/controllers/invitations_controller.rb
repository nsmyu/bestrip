class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary

  def create
    @invitation_code = SecureRandom.urlsafe_base64
    Invitation.create(itinerary_id: @itinerary.id, code: @invitation_code)
  end

  def destroy
    Invitation.find(params[:id]).destroy
    redirect_to :itineraries, notice: "「#{@itinerary.title}」への招待を削除しました。"
  end
end
