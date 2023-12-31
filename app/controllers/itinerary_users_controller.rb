class ItineraryUsersController < ApplicationController
  before_action -> {
    authenticate_user!
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }

  def new
  end

  def search_user
    bestrip_id = params[:bestrip_id]
    @user = User.find_by(bestrip_id: bestrip_id)
    if @user.nil?
      flash.now[:notice] = 'ユーザーが見つかりませんでした'
      render :new
    end
  end

  def create
    user = User.find(params[:user_id])
    if @itinerary.members << user
      redirect_to @itinerary, notice: "メンバーを追加しました。"
    end
  end

  def destroy
    member = User.find(params[:user_id])
    if current_user == @itinerary.owner && member != @itinerary.owner
      @itinerary.itinerary_users.find_by(user_id: member.id).destroy
      redirect_to @itinerary, notice: "メンバーから削除しました。"
    else
      redirect_to @itinerary, notice: "この操作ができるのはプラン作成者のみです。"
    end
  end
end
