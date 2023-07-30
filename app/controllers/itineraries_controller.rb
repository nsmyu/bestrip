class ItinerariesController < ApplicationController
  before_action :authenticate_user!

  def index
    @itineraries = Itinerary.where(user_id: current_user.id)
  end

  def new
    @itinerary = Itinerary.new
  end

  def create
    @user = User.find(current_user.id)
    @itinerary = @user.itineraries.new(itinerary_params)
    if @itinerary.save
      redirect_to @itinerary, notice: "新しい旅のプランを作成しました。次はスケジュールを追加してみましょう。"
    else
      render :new
    end
  end

  def show
    @itinerary = Itinerary.find(params[:id])
  end

  # def edit
  #   @room = Room.find(params[:id])
  # end

  # def update
  #   @room = Room.find(params[:id])
  #   if @room.update(room_params)
  #     flash[:notice] = "施設情報を更新しました。"
  #     redirect_to action: :show, id: @room.id
  #   else
  #     flash.now[:alert] = "入力内容に誤りがあります。"
  #     render "rooms/edit"
  #   end
  # end

  def destroy
    @itinerary = Itinerary.find(params[:id])
    deleted_title = @itinerary.title
    @itinerary.destroy
    redirect_to :itineraries, notice: "#{deleted_title}を削除しました。"
  end

  # def search
  #   @area = params[:area]
  #   @keyword = params[:keyword]
  #   if @area == nil && @keyword == nil
  #     @rooms = Room.all
  #   else
  #     @rooms = Room.where("address LIKE ?", "%#{@area}%").where("room_name LIKE ? or description LIKE ?", "%#{@keyword}%", "%#{@keyword}%")
  #   end
  # end

  private

    def itinerary_params
      params.require(:itinerary).permit(:title, :image, :departure_date, :return_date, :user_id)
    end

end
