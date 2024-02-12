class CommentsController < ApplicationController
  before_action -> {
    authenticate_user!
  }

  def create
    @post = Post.find(params[:id])
    @comment = @post.comments.new(comment_params.merge(user_id: current_user.id))
    @comment.save
    @new_comment = @post.comments.new(user: current_user)
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
