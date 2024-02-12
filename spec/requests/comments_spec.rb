require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:itinerary) { create(:itinerary, owner: other_user) }
  let(:test_post) { create(:post, :with_photo, itinerary: itinerary) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        comment = build(:comment, user_id: user.id)
        comment_params = { content: comment.content, user_id: comment.user_id }
        post comments_path(test_post.id), params: { comment: comment_params }, headers: turbo_stream
        expect(response.body).to include comment.content
      end
    end

    context "無効な値の場合" do
      it "コメント本文が空欄の場合、失敗すること" do
        comment = build(:comment, content: "", user_id: user.id)
        comment_params = { content: comment.content, user_id: comment.user_id }
        post comments_path(test_post.id), params: { comment: comment_params }, headers: turbo_stream
        expect(test_post.reload.comments).not_to include comment
      end

      it "コメント本文が空欄の場合、失敗すること" do
        comment = build(:comment, content: "a" * 1001, user_id: user.id)
        comment_params = { content: comment.content, user_id: comment.user_id }
        post comments_path(test_post.id), params: { comment: comment_params }, headers: turbo_stream
        expect(test_post.reload.comments).not_to include comment
      end
    end
  end
end
