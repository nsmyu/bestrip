class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i(new create edit update destroy)
  before_action :set_post, only: %i(show edit update destroy)
  before_action :authenticate_post_owner, only: %i(edit update destroy)

  def index
    @posts = Post.includes([:user, :photos]).order(created_at: :desc).page(params[:page]).per(9)
  end

  def search
    @keyword = params[:keyword]
    itineraries = Itinerary.contains_keyword(@keyword)
    @posts = Post.contains_keyword(@keyword).includes([:user, :photos])
      .or(Post.belongs_to_itineraries_containing_keyword(itineraries).includes([:user, :photos]))
      .order(created_at: :desc)
      .page(params[:page]).per(9)
  end

  def new
    @itineraries = current_user.itineraries.order(departure_date: :desc)
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
    @new_comment = @post.comments.new(user: current_user)
    sort_comments(@post.comments.where(parent_id: nil))

    if @post.itinerary_public?
      unsorted_schedules = @post.itinerary.schedules
      sort_schedules_by_date_time(unsorted_schedules)
      date_list = (@post.itinerary.departure_date..@post.itinerary.return_date).to_a
      @day_schedules = @schedules.map do |date, schedules|
        [
          date ? (date_list.index(date).to_i + 1).to_s + "日目" : "その他の予定",
          schedules,
        ]
      end
    end
  end

  def edit
    @itineraries = current_user.itineraries.order(departure_date: :desc)
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
      redirect_to :root, notice: "この操作ができるのは投稿者のみです。"
    end
  end

  def post_params
    params.require(:post).permit(:title,
                                 :caption,
                                 :itinerary_public,
                                 :itinerary_id,
                                 [photos_attributes: [:url, :id, :_destroy]])
  end

  def sort_comments(comments)
    return if !current_user

    time_sorted_comments = comments.includes(:user).order(created_at: :desc)
    if comments.where(user_id: current_user.id).count.zero?
      @comments = time_sorted_comments.page(params[:page]).per(5)
    else
      user_id_parted_comments = time_sorted_comments.partition do |comment|
        comment.user_id == current_user.id
      end .flatten
      @comments = Kaminari.paginate_array(user_id_parted_comments).page(params[:page]).per(5)
    end
  end
end
