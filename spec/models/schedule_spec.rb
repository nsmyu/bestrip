require 'rails_helper'

RSpec.describe Schedule, type: :model do
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
    schedule = build(:schedule, schedule_date: "2024-01-31", itinerary: itinerary)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:schedule_date, "出発日〜帰宅日の間で選択してください")
  end

  it "スケジュールの日付が帰宅日より後の場合は無効であること" do
    itinerary = create(:itinerary)
    schedule = build(:schedule, schedule_date: "2024-02-09", itinerary: itinerary)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:schedule_date, "出発日〜帰宅日の間で選択してください")
  end

  it "タイトルが51文字以上の場合は無効であること" do
    schedule = build(:schedule, note: "a" * 501)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:note, :too_long)
  end

  it "itinerary_idがなければ無効であること" do
    schedule = build(:schedule, schedule_date: nil, itinerary: nil)
    schedule.valid?
    expect(schedule.errors).to be_of_kind(:itinerary, :blank)
  end
end
