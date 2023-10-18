class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_post_owner, only: [:edit, :update, :destroy]

  def index
    @posts = Post.all.order(created_at: :desc)
  end

  def new
    @current_users_itineraries = current_user.itineraries.pluck(:title, :id)
    @post = Post.new
    @post.photos.build
  end

  def create
    @post = User.find(current_user.id).posts.new(post_params)
    if @post.save
      redirect_to @post, notice: "旅の思い出を投稿しました。"
    end
  end

  def show
    if @post.itinerary_public?
      schedules = @post.itinerary.schedules
      sort_schedules_by_date_time(schedules)
      @date_list = (@post.itinerary.departure_date..@post.itinerary.return_date).to_a
    end
  end

  def edit
    @current_users_itineraries = current_user.itineraries.pluck(:title, :id)
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "旅の思い出を更新しました。"
    end
  end

  def destroy
    @post.destroy
    redirect_to :posts, notice: "投稿を削除しました。"
  end

  private

  def post_params
    params.require(:post).permit(:title,
                                 :caption,
                                 :itinerary_public,
                                 :itinerary_id,
                                 [photos_attributes: [:url, :id, :_destroy]])
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def authenticate_post_owner
    if current_user != @post.user
      redirect_to :posts
    end
  end
end
