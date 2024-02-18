require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "バリデーション" do
    it "コメント本文、user_id、post_idがあれば有効であること" do
      expect(build(:comment)).to be_valid
    end

    it "コメント本文がなければ無効であること" do
      comment = build(:comment, content: nil)
      comment.valid?
      expect(comment.errors).to be_of_kind(:content, :blank)
    end

    it "コメント本文が空欄の場合は無効であること" do
      comment = build(:comment, content: " ")
      comment.valid?
      expect(comment.errors).to be_of_kind(:content, :blank)
    end

    it "コメント本文が1000文字以下であれば有効であること" do
      expect(build(:comment, content: "a" * 1000)).to be_valid
    end

    it "コメント本文が1001文字以上の場合は無効であること" do
      comment = build(:comment, content: "a" * 1001)
      comment.valid?
      expect(comment.errors).to be_of_kind(:content, :too_long)
    end

    it "user_idがなければ無効であること" do
      comment = build(:comment, user: nil)
      comment.valid?
      expect(comment.errors).to be_of_kind(:user, :blank)
    end

    it "post_idがなければ無効であること" do
      comment = build(:comment, post: nil)
      comment.valid?
      expect(comment.errors).to be_of_kind(:post, :blank)
    end
  end

  describe "子モデルのレコード削除" do
    it "commentを削除すると関連するreplyも削除されること" do
      post = create(:post, :with_photo)
      comment = create(:comment, post: post)
      create(:comment, parent: comment, post: post)
      expect { comment.destroy }.to change { Comment.count }.by(-2)
    end
  end
end
