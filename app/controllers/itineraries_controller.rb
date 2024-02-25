class ItinerariesController < ApplicationController
  before_action :authenticate_user!
  before_action -> {
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }, only: %i(show edit update destroy)
  before_action :authenticate_itinerary_owner, only: %i(edit update destroy)

  def index
    @itineraries = current_user.itineraries.includes(:members).order(departure_date: :desc)
    @invited_itineraries = current_user.invited_itineraries.order(:created_at)
    if params[:invited_itinerary_id].present?
      @invited_itinerary = Itinerary.find(params[:invited_itinerary_id])
      @pending_invitation = current_user.pending_invitations.find_by(itinerary_id: @invited_itinerary.id)
      p @invited_itinerary.inspect
      p "FFFF"
    end
  end

  def new
    @itinerary = Itinerary.new
  end

  def create
    user = User.find(current_user.id)
    @itinerary = user.owned_itineraries.new(itinerary_params)
    if @itinerary.save
      redirect_to @itinerary, notice: "新しい旅のプランを作成しました。"
    end
  end

  def show
    @itinerary_members = @itinerary.members.order("itinerary_users.id")
      .partition { |member| member.id == current_user.id }.flatten
  end

  def edit
  end

  def update
    if @itinerary.update(itinerary_params)
      redirect_to @itinerary, notice: "旅のプラン情報を変更しました。"
    end
  end

  def destroy
    @itinerary.destroy
    redirect_to :itineraries, notice: "旅のプランを削除しました。"
  end

  private

  def authenticate_itinerary_owner
    if current_user != @itinerary.owner
      redirect_to @itinerary, notice: "この操作ができるのはプラン作成者のみです。"
    end
  end

  def itinerary_params
    params.require(:itinerary).permit(:title, :image, :departure_date, :return_date, :user_id)
  end
end
