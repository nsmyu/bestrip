require 'rails_helper'

RSpec.describe Post, type: :model, focus: true do
  it "タイトル、写真、itinerary_id及び関連付けされたuser_idがあれば有効であること" do
    expect(build(:post)).to be_valid
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

  it "写真がなければ無効であること" do
    post = build(:post, photos: nil)
    post.valid?
    expect(post.errors).to be_of_kind(:photos, :blank)
  end

  it "キャプションが1001文字以上の場合は無効であること" do
    post = build(:post, caption: "a" * 1001)
    post.valid?
    expect(post.errors).to be_of_kind(:caption, :too_long)
  end

  it "itinerary_id及び関連付けされたuser_idがなければ無効であること" do
    post = build(:post, itinerary: nil, user: nil)
    post.valid?
    expect(post.errors).to be_of_kind(:itinerary, :blank)
  end
end
