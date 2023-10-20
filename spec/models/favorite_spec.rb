require 'rails_helper'

RSpec.describe Favorite, type: :model, focus: true do
  it "place_id、user_idがあれば有効であること" do
    expect(build(:favorite)).to be_valid
  end

  it "place_idがなければ無効であること" do
    favorite = build(:favorite, place_id: nil)
    favorite.valid?
    expect(favorite.errors).to be_of_kind(:place_id, :blank)
  end

  it "同じユーザーでplace_idが重複している場合は無効であること" do
    favorite = create(:favorite)
    other_favorite =
      build(:favorite, place_id: favorite.place_id, user: favorite.user)
    other_favorite.valid?
    expect(other_favorite.errors).to be_of_kind(:place_id, :taken)
  end

  it "itinerary_idがなければ無効であること" do
    favorite = build(:favorite, user: nil)
    favorite.valid?
    expect(favorite.errors).to be_of_kind(:user, :blank)
  end

  it "ユーザー一人につき301個以上の登録は無効であること" do
    user = create(:user)
    expect { create_list(:favorite, 301, user: user) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end
end
