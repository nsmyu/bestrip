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
      flash[:notice] = "新しい旅のプランを作成しました。次はスケジュールを追加してみましょう。"
      respond_to do |format|
        format.html { redirect_to itineraries_url }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @itinerary = Itinerary.find(params[:id])
  end

  def edit
    @itinerary = Itinerary.find(params[:id])
  end

  def update
    @itinerary = Itinerary.find(params[:id])

    if @itinerary.update(itinerary_params)
      flash[:notice] = "施設情報を更新しました。"
      redirect_to action: :show, id: @itinerary_params.id
    else
      render :edit
    end
  end

  def destroy
    @itinerary = Itinerary.find(params[:id])
    deleted_title = @itinerary.title
    @itinerary.destroy
    redirect_to :itineraries, notice: "#{deleted_title}を削除しました。"
  end

  private

  def itinerary_params
    params.require(:itinerary).permit(:title, :image, :image_cache, :departure_date, :return_date, :user_id)
  end
end
