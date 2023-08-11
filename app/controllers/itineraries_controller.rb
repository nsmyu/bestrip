class ItinerariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary, except: [:index, :new, :create, :search_user]

  def index
    @itineraries = Itinerary.where(user_id: current_user.id).order(departure_date: :desc)
  end

  def new
    @itinerary = Itinerary.new
  end

  def create
    @user = User.find(current_user.id)
    @itinerary = @user.owned_itineraries.new(itinerary_params)
    if @itinerary.save
      @itinerary.users << @user
      redirect_to @itinerary, notice: "新しい旅のプランを作成しました。次はスケジュールを追加してみましょう。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @itinerary.update(itinerary_params)
      redirect_to @itinerary, notice: "旅のプラン情報を変更しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new_member
  end

  def search_user
    @bestrip_id = params[:bestrip_id]
    @user = User.find_by(bestrip_id: @bestrip_id)
    render :new_member if @user.nil?
  end

  def add_member
    @user = User.find(params[:user_id])
    @itinerary.members << @user
    redirect_to @itinerary
  end

  def destroy
    deleted_title = @itinerary.title
    @itinerary.destroy
    redirect_to :itineraries, notice: "#{deleted_title}を削除しました。"
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
