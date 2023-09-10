FactoryBot.define do
  factory :schedule do
    sequence(:title) { |n| "Schedule_#{n}" }
    schedule_date { "2024-02-02" }
    start_at      { "13:00:00" }
    end_at        { "17:00:00" }
    icon          { "attraction" }
    place_name    { "沖縄美ら海水族館" }
    address       { "日本、〒905-0206 沖縄県国頭郡本部町石川４２４" }
    place_id      { "ChIJPZ5hUjH65DQR_p_dD3CmCOo" }
    itinerary
  end
end
