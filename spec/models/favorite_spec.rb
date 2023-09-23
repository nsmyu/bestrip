require 'rails_helper'

RSpec.describe Favorite, type: :model do
  it "place_id、itinerary_idがあれば有効であること" do
    expect(build(:favorite)).to be_valid
  end

  it "place_idがなければ無効であること" do
    favorite = build(:favorite, place_id: nil)
    favorite.valid?
    expect(favorite.errors).to be_of_kind(:place_id, :blank)
  end

  it "itinerary_idがなければ無効であること" do
    favorite = build(:favorite, itinerary: nil)
    favorite.valid?
    expect(favorite.errors).to be_of_kind(:itinerary, :blank)
  end
end
