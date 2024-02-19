class ItineraryUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary, only: %i(new create)
  before_action -> {
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }, only: %i(find_by_bestrip_id search_user invite_user destroy)

  def new
  end

  def find_by_bestrip_id
  end

  def search_user
    bestrip_id = params[:bestrip_id]
    @user = User.find_by(bestrip_id: bestrip_id)
    if @user.nil?
      flash.now[:notice] = 'ユーザーが見つかりませんでした'
      render :find_by_bestrip_id
    end
  end

  def invite_user
    user = User.find(params[:user_id])
    Invitation.create(invitee: user, invited_to_itinerary: @itinerary)
    redirect_to @itinerary, notice: "#{user.name}さんを招待しました。#{user.name}さんが参加するのをお待ちください。"
  end

  def create
    user = User.find(params[:user_id])
    if @itinerary.members << user
      user.invitations.find_by(itinerary_id: @itinerary.id)&.destroy
      redirect_to :itineraries, notice: "旅のプランに参加しました。"
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
