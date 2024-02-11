class LikesController < ApplicationController
  before_action -> {
    authenticate_user!
  }

  def index
  end

  def create
    @post = Post.find(params[:id])
    like = current_user.likes.new(post: @post)
    like.save
  end

  def destroy
    @post = Post.find(params[:id])
    current_user.likes.find_by(post_id: @post.id).destroy
  end
end
