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
    params.require(:post).permit(:title, :caption, { photos: [] })
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end
