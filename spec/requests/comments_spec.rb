require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:test_post) { create(:post, :with_photo) }
  let(:comment) { create(:comment, post: test_post) }
  let(:reply_1) { create(:comment, post: test_post, parent: comment) }
  let(:reply_2) { create(:comment, post: test_post, parent: comment) }
  let(:turbo_stream) { { accept: "text/vnd.turbo-stream.html" } }

  before do
    sign_in user
  end

  describe "POST #create" do
    context "有効な値の場合" do
      it "成功すること" do
        comment = build(:comment, user: user)
        comment_params = { content: comment.content, user: comment.user }
        post post_comments_path(test_post.id), params: { comment: comment_params }, headers: turbo_stream
        expect(response.body).to include comment.content
      end
    end

    context "無効な値の場合" do
      it "コメント本文が空欄の場合、失敗すること" do
        comment = build(:comment, content: "", user: user)
        comment_params = { content: comment.content, user: comment.user }
        post post_comments_path(test_post.id), params: { comment: comment_params }, headers: turbo_stream
        expect(response).to redirect_to post_path(test_post.id)
        expect(test_post.reload.comments_count).to eq 0
      end

      it "コメント本文が1001文字以上の場合、失敗すること" do
        comment = build(:comment, content: "a" * 1001, user: user)
        comment_params = { content: comment.content, user: comment.user }
        post post_comments_path(test_post.id), params: { comment: comment_params }, headers: turbo_stream
        expect(response).to redirect_to post_path(test_post.id)
        expect(test_post.reload.comments_count).to eq 0
      end
    end
  end

  describe "GET #new_reply" do
    it "正常にレスポンスを返すこと" do
      get post_new_reply_path(test_post.id), params: { comment_id: comment.id }
      expect(response).to have_http_status 200
    end
  end

  describe "GET #show_replies" do
    before do
      reply_1
      reply_2
    end

    it "正常にレスポンスを返すこと" do
      get post_show_replies_path(test_post.id), params: { comment_id: comment.id }
      expect(response).to have_http_status 200
    end

    it "コメントへの返信を全て取得すること" do
      get post_show_replies_path(test_post.id), params: { comment_id: comment.id }
      expect(response.body).to include reply_1.user.name, reply_1.content
      expect(response.body).to include reply_2.user.name, reply_2.content
    end

    it "返信を非表示にするためのリンクを取得すること" do
      get post_show_replies_path(test_post.id), params: { comment_id: comment.id }
      expect(response.body).to include "返信を非表示にする"
    end
  end

  describe "GET #hide_replies" do
    before do
      reply_1
      reply_2
    end

    it "正常にレスポンスを返すこと" do
      get post_hide_replies_path(test_post.id), params: { comment_id: comment.id }
      expect(response).to have_http_status 200
    end

    it "返信を表示するためのリンクを取得すること" do
      get post_hide_replies_path(test_post.id), params: { comment_id: comment.id }
      expect(response.body).to include "返信2件を表示する"
    end
  end

  describe "GET #destroy" do
    context "有効な値の場合" do
      it "ログインユーザーがコメント投稿者の場合、成功すること" do
        comment = create(:comment, user: user, post: test_post)
        delete post_comment_path(post_id: test_post.id, id: comment.id), headers: turbo_stream
        expect(test_post.reload.comments).not_to include comment
      end

      it "ログインユーザーがpost投稿者の場合、成功すること" do
        comment
        sign_in test_post.user
        delete post_comment_path(post_id: test_post.id, id: comment.id), headers: turbo_stream
        expect(test_post.reload.comments).not_to include comment
      end
    end

    context "無効な値の場合" do
      it "ログインユーザーがコメントの投稿者でもpostの投稿者でもない場合、失敗すること" do
        comment
        random_user = create(:user)
        sign_in random_user

        delete post_comment_path(post_id: test_post.id, id: comment.id), headers: turbo_stream
        expect(response).to redirect_to post_path(test_post.id)
        expect(test_post.reload.comments).to include comment
      end
    end
  end
end
