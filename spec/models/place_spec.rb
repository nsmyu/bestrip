require 'rails_helper'

RSpec.describe Place, type: :model do
  it "place_idがあり、placeableに関連付けられていれば有効であること" do
    expect(build(:user_place)).to be_valid
  end

  it "place_idがなければ無効であること" do
    user_place = build(:user_place, place_id: nil)
    user_place.valid?
    expect(user_place.errors).to be_of_kind(:place_id, :blank)
  end

  it "同じplaceable関連付けでplace_idが重複している場合は無効であること" do
    user_place = create(:user_place)
    other_user_place =
      build(:user_place, place_id: user_place.place_id,
                         placeable: user_place.placeable)
    other_user_place.valid?
    expect(other_user_place.errors).to be_of_kind(:place_id, :taken)
  end

  it "placeableに関連付いていなければ無効であること" do
    user_place = build(:user_place, placeable: nil)
    user_place.valid?
    expect(user_place.errors).to be_of_kind(:placeable, :blank)
  end

  it "ひとつのplaceableにつき、301個以上の関連付けは無効であること" do
    user = create(:user)
    create_list(:user_place, 300, placeable: user)
    user_place = build(:user_place, placeable: user)
    user_place.valid?
    expect(user_place.errors).to be_of_kind(:placeable_id, "スポットの登録数が上限に達しています")
  end
end
