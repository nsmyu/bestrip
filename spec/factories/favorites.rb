FactoryBot.define do
  factory :favorite do
    sequence(:place_id) { |n| "place_id_#{n}" }
    itinerary

    trait :opera_house do
      place_id { "ChIJ3S-JXmauEmsRUcIaWtf4MzE" }
    end

    trait :queen_victoria_building do
      place_id { "ChIJISz8NjyuEmsRFTQ9Iw7Ear8" }
    end
  end
end
