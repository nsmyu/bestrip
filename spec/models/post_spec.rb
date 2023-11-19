require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "バリデーション" do
    it "タイトル、itinerary_id、user_idがあり、photosが1つ以上関連付けられていれば有効であること" do
      expect(build(:post, :with_photo, caption: nil)).to be_valid
    end

    it "タイトルがなければ無効であること" do
      post = build(:post, :with_photo, title: nil)
      post.valid?
      expect(post.errors).to be_of_kind(:title, :blank)
    end

    it "タイトルは30文字以下であれば有効であること" do
      expect(build(:post, :with_photo, title: "a" * 30)).to be_valid
    end

    it "タイトルが31文字以上の場合は無効であること" do
      post = build(:post, :with_photo, title: "a" * 31)
      post.valid?
      expect(post.errors).to be_of_kind(:title, :too_long)
    end

    it "キャプションは1000文字以下であれば有効であること" do
      expect(build(:post, :with_photo, caption: "a" * 1000)).to be_valid
    end

    it "キャプションが1001文字以上の場合は無効であること" do
      post = build(:post, :with_photo, caption: "a" * 1001)
      post.valid?
      expect(post.errors).to be_of_kind(:caption, :too_long)
    end

    it "photosが関連付けられていない場合は無効であること" do
      post = build(:post)
      post.valid?
      expect(post.errors).to be_of_kind(:photos, :too_short)
    end

    it "photosの関連付けは20個以下であれば有効であること" do
      post = create(:post, :with_photo)
      post.photos << build_list(:photo, 19)
      expect(post).to be_valid
    end

    it "photosが21個以上関連付けられている場合は無効であること" do
      post = create(:post, :with_photo)
      post.photos << build_list(:photo, 20)
      post.valid?
      expect(post.errors).to be_of_kind(:photos, :too_long)
    end

    it "itinerary_idがなければ無効であること" do
      post = build(:post, :with_photo, itinerary: nil)
      post.valid?
      expect(post.errors).to be_of_kind(:itinerary, :blank)
    end

    it "user_idがなければ無効であること" do
      post = build(:post, :with_photo, user: nil)
      post.valid?
      expect(post.errors).to be_of_kind(:user, :blank)
    end
  end

  describe "子モデルのレコード削除" do
    it "postを削除すると関連するphotoも削除されること" do
      post = create(:post, :with_photo)
      expect { post.destroy }.to change { Photo.count }.by(-1)
    end
  end
end
