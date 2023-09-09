FactoryBot.define do
  factory :schedule do
    sequence(:title) { |n| "Schedule_#{n}" }
    schedule_date { "2024-02-01" }
    start_at      { "13:00:00" }
    end_at        { "17:00:00" }
    icon          { "attraction" }
  end
end
