FactoryBot.define do
  factory :user_place, class: "Place" do
    sequence(:place_id) { |n| "place_id_#{n}" }
    placeable_type { "User" }
    association :placeable, factory: :user

    trait :opera_house do
      place_id { "ChIJ3S-JXmauEmsRUcIaWtf4MzE" }
    end

    trait :queen_victoria_building do
      place_id { "ChIJISz8NjyuEmsRFTQ9Iw7Ear8" }
    end
  end

  factory :itinerary_place, class: "Place" do
    sequence(:place_id) { |n| "place_id_#{n}" }
    placeable_type { "Itinerary" }
    association :placeable, factory: :itinerary

    trait :opera_house do
      place_id { "ChIJ3S-JXmauEmsRUcIaWtf4MzE" }
    end

    trait :queen_victoria_building do
      place_id { "ChIJISz8NjyuEmsRFTQ9Iw7Ear8" }
    end
  end
end
