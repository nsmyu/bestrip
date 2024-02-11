class LikesController < ApplicationController
  before_action -> {
    authenticate_user!
  }

  def index
  end

  def create
    @post = Post.find(params[:id])
    like = @post.likes.new(user: current_user)
    like.save
  end

  def destroy
    @post = Post.find(params[:id])
    @post.likes.find_by(user_id: current_user.id).destroy
  end
end
