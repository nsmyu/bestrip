require 'rails_helper'

RSpec.describe Photo, type: :model do
  describe "バリデーション" do
    it "urlとpost_idがあれば有効であること" do
      expect(build(:photo)).to be_valid
    end

    it "urlがなければ無効であること" do
      photo = build(:photo, url: nil)
      photo.valid?
      expect(photo.errors).to be_of_kind(:url, :blank)
    end

    it "post_idがなければ無効であること" do
      photo = build(:photo, post: nil)
      photo.valid?
      expect(photo.errors).to be_of_kind(:post, :blank)
    end
  end
end
