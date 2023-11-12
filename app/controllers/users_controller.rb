class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.all.includes(:photos).order(created_at: :desc)
  end
end
