class ItinerariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary, :authenticate_itinerary_member, except: [:index, :new, :create]

  def index
    @itineraries = current_user.itineraries.order(departure_date: :desc)
  end

  def search_place
    @query = params[:query]
    @client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    return if @query.blank?
    @places = @client.spots_by_query(@query, language: 'ja').first(10)
  end

  def show_place
    @client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    @place = @client.spot("ChIJH2P5xULYA2ARc3LaL8TMe7I", language: 'ja')
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
    else
      render :new, status: :unprocessable_entity
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
    else
      render :edit, status: :unprocessable_entity
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
    params.require(:itinerary)
      .permit(:title, :image, :image_cache, :departure_date, :return_date, :user_id)
  end

  def set_itinerary
    @itinerary = Itinerary.find(params[:id])
  end
end
