class PostsController < ApplicationController
  before_action :authenticate_user!, except: %i(index show)
  before_action :set_post, only: %i(show edit update destroy)
  before_action :authenticate_post_owner, only: %i(edit update destroy)

  def index
    @posts = Post.order(created_at: :desc).page(params[:page]).per(9)
  end

  def search
    itinerary_with_keyword = Itinerary.has_keyword(params[:keyword])
    @posts = Post.has_keyword(params[:keyword], itinerary_with_keyword)
      .order(created_at: :desc)
      .page(params[:page]).per(9)
  end

  def new
    @itineraries = current_user.itineraries
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
    @itineraries = current_user.itineraries
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

  def set_post
    @post = Post.find(params[:id])
  end

  def authenticate_post_owner
    if current_user != @post.user
      redirect_to :posts
    end
  end

  def post_params
    params.require(:post).permit(:title,
                                 :caption,
                                 :itinerary_public,
                                 :itinerary_id,
                                 [photos_attributes: [:url, :id, :_destroy]])
  end

  # def search_params

  # end
end
