require 'rails_helper'

RSpec.describe Itinerary, type: :model do
  it "タイトル、出発日、帰宅日、user_id(owner)があれば有効であること" do
    expect(create(:itinerary)).to be_valid
  end

  it "タイトルがなければ無効であること" do
    itinerary = build(:itinerary, title: nil)
    itinerary.valid?
    expect(itinerary.errors).to be_of_kind(:title, :blank)
  end

  it "タイトルが31文字以上の場合は無効であること" do
    itinerary = build(:itinerary, title: "a" * 31)
    itinerary.valid?
    expect(itinerary.errors).to be_of_kind(:title, :too_long)
  end

  it "同一ユーザーでタイトルが重複している場合は無効であること" do
    itinerary = create(:itinerary)
    other_itinerary = build(:itinerary, title: itinerary.title, owner: itinerary.owner)
    other_itinerary.valid?
    expect(other_itinerary.errors).to be_of_kind(:title, :taken)
  end

  it "出発日がなければ無効であること" do
    itinerary = build(:itinerary, departure_date: nil)
    itinerary.valid?
    expect(itinerary.errors).to be_of_kind(:departure_date, :blank)
  end

  it "帰宅日がなければ無効であること" do
    itinerary = build(:itinerary, return_date: nil)
    itinerary.valid?
    expect(itinerary.errors).to be_of_kind(:return_date, :blank)
  end

  it "帰宅日が出発日より前の場合は無効であること" do
    itinerary = build(:itinerary, departure_date: "2024-03-04", return_date: "2024-03-01")
    itinerary.valid?
    expect(itinerary.errors).to be_of_kind(:return_date, "は出発日以降で選択してください")
  end

  it "user_id(owner)がなければ無効であること" do
    itinerary = build(:itinerary)
    itinerary.owner = nil
    itinerary.valid?
    expect(itinerary.errors).to be_of_kind(:owner, :blank)
  end
end
