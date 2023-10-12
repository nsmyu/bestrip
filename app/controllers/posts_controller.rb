class PostsController < ApplicationController

  # before_action -> {
  #   authenticate_user!
  #   set_itinerary
  #   authenticate_itinerary_member(@itinerary)
  # }
  # before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  MAX_PHOTOS_COUNT = 5

  def index
  end

  def new
    authenticate_user!
    @current_users_itineraries = current_user.itineraries.pluck(:title, :id)
    @post = Post.new
    MAX_PHOTOS_COUNT.times { @post.photos.build }
  end

  def create
    @current_users_itineraries = current_user.itineraries.pluck(:title, :id)
    @post = User.find(current_user.id).posts.new(post_params)
    if @post.save
      redirect_to :posts, notice: "旅の思い出を投稿しました。"
    end
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
    params.require(:post).permit(:title, :caption, :itinerary_id, [photos_attributes: [:url]])
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end
