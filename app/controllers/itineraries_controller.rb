class ItinerariesController < ApplicationController
  def index
    @itineraries = Itinerary.where(user_id: current_user.id)
  end

  def new
    @itinerary = Itinerary.new
  end

  # def create
  #   @room = Room.new(room_params)
  #   if @room.save
  #     flash[:notice] = "新しい施設の登録が完了しました。"
  #     redirect_to action: :show, id: @room.id
  #   else
  #     flash.now[:alert] = "入力内容に誤りがあります。"
  #     render "rooms/new"
  #   end
  # end

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

  # def destroy
  #   @room = Room.find(params[:id])
  #   @room.destroy
  #   redirect_to :rooms
  # end

  # def search
  #   @area = params[:area]
  #   @keyword = params[:keyword]
  #   if @area == nil && @keyword == nil
  #     @rooms = Room.all
  #   else
  #     @rooms = Room.where("address LIKE ?", "%#{@area}%").where("room_name LIKE ? or description LIKE ?", "%#{@keyword}%", "%#{@keyword}%")
  #   end
  # end

  # private

  # def room_params
  #   params.require(:room).permit(:room_name, :description, :price, :address, :image, :user_id)
  # end

end
