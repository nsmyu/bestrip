class ItineraryUsersController < ApplicationController
  before_action -> {
    authenticate_user!
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }

  def new
  end

  def search_user
    @bestrip_id = params[:bestrip_id]
    @user = User.find_by(bestrip_id: @bestrip_id)
    if @user.nil?
      flash.now[:notice] = 'ユーザーが見つかりませんでした'
      render :new
    end
  end

  def create
    user = User.find(params[:user_id])
    @itinerary.members << user
    redirect_to @itinerary
  end

  def destroy
    member = User.find(params[:user_id])
    if current_user == @itinerary.owner && member != @itinerary.owner
      @itinerary.itinerary_users.find_by(user_id: member.id).destroy
      redirect_to @itinerary
    else
      redirect_to @itinerary
    end
  end
end
