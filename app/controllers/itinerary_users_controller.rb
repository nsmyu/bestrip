class ItineraryUsersController < ApplicationController
  before_action :authenticate_user!, :authenticate_itinerary_member
  before_action :set_itinerary

  def new_member
  end

  def search_user
    @bestrip_id = params[:bestrip_id]
    @user = User.find_by(bestrip_id: @bestrip_id)
    if @user.nil?
      flash.now[:notice] = 'ユーザーが見つかりませんでした'
      render :new_member
    end
  end

  def add_member
    user = User.find(params[:user_id])
    @itinerary.members << user
    redirect_to @itinerary
  end

  def remove_member
    member = User.find(params[:user_id])
    if current_user == @itinerary.owner && member != @itinerary.owner
      @itinerary.itinerary_users.find_by(user_id: member.id).destroy
      redirect_to @itinerary
    else
      redirect_to @itinerary
    end
  end

  private

  def itinerary_params
    params.require(:itinerary)
      .permit(:title, :image, :image_cache, :departure_date, :return_date, :user_id)
  end

  def set_itinerary
    @itinerary = Itinerary.find(params[:id])
  end
end
