FactoryBot.define do
  factory :schedule do
    opera_house_id = "ChIJ3S-JXmauEmsRUcIaWtf4MzE"

    sequence(:title) { |n| "Schedule_#{n}" }
    date { "2024-02-02" }
    start_at      { "13:00:00" }
    end_at        { "17:00:00" }
    icon          { "castle" }
    place_id      { opera_house_id }
    note          { "The Sydney Opera House Tour, 2:00pm, $43" }
    itinerary
  end
end
