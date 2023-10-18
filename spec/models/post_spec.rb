require 'rails_helper'

RSpec.describe Post, type: :model do
  it "タイトル、itinerary_idがあり、写真が1枚以上紐付けられていれば有効であること" do
    expect(build(:post, :with_photo)).to be_valid
  end

  it "タイトルがなければ無効であること" do
    post = build(:post, title: nil)
    post.valid?
    expect(post.errors).to be_of_kind(:title, :blank)
  end

  it "タイトルが31文字以上の場合は無効であること" do
    post = build(:post, title: "a" * 31)
    post.valid?
    expect(post.errors).to be_of_kind(:title, :too_long)
  end

  it "キャプションが1001文字以上の場合は無効であること" do
    post = build(:post, caption: "a" * 1001)
    post.valid?
    expect(post.errors).to be_of_kind(:caption, :too_long)
  end

  it "写真が1枚も紐付けされていない場合は無効であること" do
    post = build(:post)
    post.valid?
    expect(post.errors).to be_of_kind(:photos, :too_short)
  end

  it "写真が21枚以上紐付けされている場合は無効であること" do
    post = create(:post, :with_photo)
    post.photos << build_list(:photo, 20)
    post.valid?
    expect(post.errors).to be_of_kind(:photos, :too_long)
  end

  it "itinerary_idがなければ無効であること" do
    post = build(:post, itinerary: nil)
    post.valid?
    expect(post.errors).to be_of_kind(:itinerary, :blank)
  end

  it "user_idがなければ無効であること" do
    post = build(:post, user: nil)
    post.valid?
    expect(post.errors).to be_of_kind(:user, :blank)
  end
end
