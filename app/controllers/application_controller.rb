class ApplicationController < ActionController::Base
  private

  def authenticate_itinerary_member
    if params[:itinerary_id]
      itinerary = Itinerary.find(params[:itinerary_id])
    else
      itinerary = Itinerary.find(params[:id])
    end
    redirect_to :root if itinerary.members.exclude?(current_user)
  end
end
