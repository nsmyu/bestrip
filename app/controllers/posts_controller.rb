class PostsController < ApplicationController

  # before_action -> {
  #   authenticate_user!
  #   set_itinerary
  #   authenticate_itinerary_member(@itinerary)
  # }
  # before_action :set_schedule, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
    authenticate_user!
    @current_users_itineraries = Itinerary.where(user_id: current_user.id).pluck(:title, :id)

    @post = Post.new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def post_params
    params.require(:post).permit(:title,  { photos: [] }, :caption, :itinerary_users_id)
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end
