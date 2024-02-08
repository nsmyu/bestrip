class LikesController < ApplicationController
  before_action -> {
    authenticate_user!
  }

  def index
  end

  def create
    post = Post.find(params[:id])
    like = current_user.likes.new(post: post)
    like.save
  end

  def destroy
  end
end
