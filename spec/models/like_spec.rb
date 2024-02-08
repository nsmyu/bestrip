require 'rails_helper'

RSpec.describe Like, type: :model do
  describe "バリデーション" do
    it "user_id、post_idがあれば有効であること" do
      expect(build(:like)).to be_valid
    end

    it "user_idがなければ無効であることと" do
      like = build(:like, user: nil)
      like.valid?
      expect(like.errors).to be_of_kind(:user, :blank)
    end

    it "post_idがなければ無効であることと" do
      like = build(:like, post: nil)
      like.valid?
      expect(like.errors).to be_of_kind(:post, :blank)
    end
  end
end
