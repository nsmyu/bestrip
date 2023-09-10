FactoryBot.define do
  factory :schedule do
    sequence(:title) { |n| "Schedule_#{n}" }
    schedule_date { "2024-02-02" }
    start_at      { "13:00:00" }
    end_at        { "17:00:00" }
    icon          { "attraction" }
    place_id      { "ChIJPZ5hUjH65DQR_p_dD3CmCOo" }
    itinerary
  end
end
