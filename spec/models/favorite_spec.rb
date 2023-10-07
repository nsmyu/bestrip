require 'rails_helper'

RSpec.describe Favorite, type: :model, focus: true do
  it "place_id、itinerary_idがあれば有効であること" do
    expect(build(:favorite)).to be_valid
  end

  it "place_idがなければ無効であること" do
    favorite = build(:favorite, place_id: nil)
    favorite.valid?
    expect(favorite.errors).to be_of_kind(:place_id, :blank)
  end

  it "同じ旅のプランでplace_idが重複している場合は無効であること" do
    favorite = create(:favorite)
    other_favorite = build(:favorite, place_id: favorite.place_id, itinerary: favorite.itinerary)
    other_favorite.valid?
    expect(other_favorite.errors).to be_of_kind(:place_id, :taken)
  end

  it "itinerary_idがなければ無効であること" do
    favorite = build(:favorite, itinerary: nil)
    favorite.valid?
    expect(favorite.errors).to be_of_kind(:itinerary, :blank)
  end

  it "ひとつのitineraryに対して301個以上の登録は無効であること" do
    itinerary = create(:itinerary)
    expect { create_list(:favorite, 301, :fake, itinerary: itinerary) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end
end
