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

  it "スケジュールの日付が出発日より前の場合は無効であること" do
    itinerary = create(:itinerary)
    schedule = build(:schedule, schedule_date: "2024-01-31", itinerary_id: itinerary.id)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:schedule_date, "出発日〜帰宅日の間で選択してください")
  end

  it "スケジュールの日付が帰宅日より後の場合は無効であること" do
    itinerary = create(:itinerary)
    schedule = build(:schedule, schedule_date: "2024-02-9", itinerary_id: itinerary.id)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:schedule_date, "出発日〜帰宅日の間で選択してください")
  end

  it "itinerary_idがなければ無効であること" do
    schedule = build(:schedule, itinerary_id: nil)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:itinerary, :blank)
  end
end
