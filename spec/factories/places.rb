FactoryBot.define do
  opera_house_id = "ChIJ3S-JXmauEmsRUcIaWtf4MzE"
  queen_victoria_building_id = "ChIJISz8NjyuEmsRFTQ9Iw7Ear8"

  factory :user_place, class: "Place" do
    sequence(:place_id) { |n| "place_id_#{n}" }
    placeable_type { "User" }
    association :placeable, factory: :user

    trait :opera_house do
      place_id { opera_house_id }
    end

    trait :queen_victoria_building do
      place_id { queen_victoria_building_id }
    end
  end

  factory :itinerary_place, class: "Place" do
    sequence(:place_id) { |n| "place_id_#{n}" }
    placeable_type { "Itinerary" }
    association :placeable, factory: :itinerary

    trait :opera_house do
      place_id { opera_house_id }
    end

    trait :queen_victoria_building do
      place_id { queen_victoria_building_id }
    end
  end
end
