require 'rails_helper'

RSpec.describe Schedule, type: :model, focus: true do
  it "タイトル、itinerary_idがあれば有効であること" do
    expect(build(:schedule)).to be_valid
  end

  it "タイトルがなければ無効であること" do
    schedule = build(:schedule, title: nil)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:title, :blank)
  end

  it "タイトルが51文字以上の場合は無効であること" do
    schedule = build(:schedule, title: "a" * 51)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:title, :too_long)
  end

  it "itinerary_idがなければ無効であること" do
    schedule = build(:schedule, itinerary_id: nil)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:itinerary, :blank)
  end
end
