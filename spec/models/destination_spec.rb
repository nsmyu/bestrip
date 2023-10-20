require 'rails_helper'

RSpec.describe Destination, type: :model do
  it "place_id、itinerary_idがあれば有効であること" do
    expect(build(:destination)).to be_valid
  end

  it "place_idがなければ無効であること" do
    destination = build(:destination, place_id: nil)
    destination.valid?
    expect(destination.errors).to be_of_kind(:place_id, :blank)
  end

  it "同じ旅のプランでplace_idが重複している場合は無効であること" do
    destination = create(:destination)
    other_destination =
      build(:destination, place_id: destination.place_id, itinerary: destination.itinerary)
    other_destination.valid?
    expect(other_destination.errors).to be_of_kind(:place_id, :taken)
  end

  it "itinerary_idがなければ無効であること" do
    destination = build(:destination, itinerary: nil)
    destination.valid?
    expect(destination.errors).to be_of_kind(:itinerary, :blank)
  end

  it "ひとつのitineraryにつき301個以上の登録は無効であること" do
    itinerary = create(:itinerary)
    expect { create_list(:destination, 301, itinerary: itinerary) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end
end
