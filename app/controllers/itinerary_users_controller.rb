class ItineraryUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary, only: :create
  before_action -> {
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }, only: %i(find_by_bestrip_id search_user destroy)

  def new
    @invited_itinerary = Itinerary.find(params[:id])
    @pending_invitation = current_user.pending_invitations.find_by(itinerary_id: @invited_itinerary.id)
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

  def create
    user = User.find(params[:user_id])
    invitation = user.pending_invitations.find_by(itinerary_id: @itinerary.id)

    if invitation
      if user == current_user
        @itinerary.members << user
        invitation.destroy
        redirect_to :itineraries, notice: "旅のプランに参加しました。"
      else
        return if @itinerary.members.exclude? current_user
        @itinerary.members << user
        invitation.destroy
        redirect_to @itinerary, notice: "#{user.name}さんを旅のメンバーに追加しました。"
      end
    else
      return if @itinerary.members.exclude? current_user
      @itinerary.members << user
      redirect_to @itinerary, notice: "#{user.name}さんを旅のメンバーに追加しました。"
    end
  end

  def destroy
    member = User.find(params[:user_id])
    if current_user == @itinerary.owner && member != @itinerary.owner
      @itinerary.itinerary_users.find_by(user_id: member.id).destroy
      redirect_to @itinerary, notice: "#{member.name}さんを旅のメンバーから削除しました。"
    else
      redirect_to @itinerary, notice: "この操作ができるのはプラン作成者のみです。"
    end
  end
end
