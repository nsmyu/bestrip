require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: other_user) }
  let(:post_1) { create(:post, :with_photo, itinerary: itinerary, user: user) }
  let(:post_2) { create(:post, :with_photo, itinerary: itinerary, user: other_user) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        comment = build(:comment, user_id: user.id)
        comment_params = { content: comment.content, user_id: comment.user_id }
        post comments_path(post_2.id), params: { comment: comment_params }, headers: turbo_stream
        expect(response.body).to include comment.content
      end
    end

    context "無効な値の場合" do
      it "コメント本文が空欄の場合、失敗すること" do
        comment = build(:comment, content: "", user_id: user.id)
        comment_params = { content: comment.content, user_id: comment.user_id }
        post comments_path(post_2.id), params: { comment: comment_params }, headers: turbo_stream
        expect(response).to redirect_to post_path(post_2.id)
        expect(post_2.reload.comments_count).to eq 0
      end

      it "コメント本文が1001文字以上の場合、失敗すること" do
        comment = build(:comment, content: "a" * 1001, user_id: user.id)
        comment_params = { content: comment.content, user_id: comment.user_id }
        post comments_path(post_2.id), params: { comment: comment_params }, headers: turbo_stream
        expect(response).to redirect_to post_path(post_2.id)
        expect(post_2.reload.comments_count).to eq 0
      end
    end
  end

  describe "GET #destroy" do
    context "有効な値の場合" do
      it "自分が他のユーザーの投稿につけたコメントを削除できること" do
        comment = create(:comment, user: user, post: post_2)
        delete comment_path(comment.id), headers: turbo_stream
        expect(post_2.reload.comments).not_to include comment
      end

      it "他のユーザーが自分の投稿につけたコメントを削除できること" do
        comment = create(:comment, user: other_user, post: post_1)
        delete comment_path(comment.id), headers: turbo_stream
        expect(post_1.reload.comments).not_to include comment
      end
    end

    context "無効な値の場合" do
      it "コメントの投稿者でもpostの投稿者でもない場合、コメントを削除できないこと" do
        comment = create(:comment, user: other_user, post: post_2)
        delete comment_path(comment.id), headers: turbo_stream
        expect(response).to redirect_to post_path(post_2.id)
        expect(post_2.reload.comments).to include comment
      end
    end
  end
end
