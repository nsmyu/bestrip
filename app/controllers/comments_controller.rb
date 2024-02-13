class CommentsController < ApplicationController
  before_action -> {
    authenticate_user!
  }

  def create
    @post = Post.find(params[:id])
    @new_comment = @post.comments.new(user: current_user)
    @comment = @post.comments.new(comment_params.merge(user_id: current_user.id))
    redirect_to @post if !@comment.save
  end

  def show_replies
    @post = Post.find(params[:id])
    @comment = Comment.find(params[:comment_id])
    @replies = Comment.where(parent_id: @comment.id).includes(:user).order(:created_at)
  end

  def destroy
    @comment = Comment.find(params[:id])
    if (current_user != @comment.user) && (current_user != @comment.post.user)
      redirect_to post_path(@comment.post.id)
      return
    end
    @comment.destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
