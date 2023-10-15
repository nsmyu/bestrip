class ItinerariesController < ApplicationController
  before_action :authenticate_user!
  before_action -> {
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }, except: [:index, :new, :create]

  def index
    @itineraries = current_user.itineraries.order(departure_date: :desc)
  end

  def new
    @itinerary = Itinerary.new
  end

  def create
    @user = User.find(current_user.id)
    @itinerary = @user.owned_itineraries.new(itinerary_params)
    if @itinerary.save
      @itinerary.members << @user
      redirect_to @itinerary, notice: "新しい旅のプランを作成しました。"
    end
  end

  def show
    @itinerary_members = @itinerary.members.order("itinerary_users.id")
  end

  def edit
  end

  def update
    if @itinerary.update(itinerary_params)
      redirect_to @itinerary, notice: "旅のプラン情報を変更しました。"
    end
  end

  def destroy
    deleted_title = @itinerary.title
    if current_user == @itinerary.owner
      @itinerary.destroy
      redirect_to :itineraries, notice: "#{deleted_title}を削除しました。"
    else
      redirect_to :itineraries
    end
  end

  private

  def itinerary_params
    params.require(:itinerary).permit(:title, :image, :departure_date, :return_date, :user_id)
  end
end
