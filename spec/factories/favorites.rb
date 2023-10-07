FactoryBot.define do
  factory :favorite do
    # シドニー・オペラハウスのplace_id
    place_id { "ChIJ3S-JXmauEmsRUcIaWtf4MzE" }
    itinerary

    trait :fake do
      sequence(:place_id) { |n| "fake_place_id_#{n}" }
    end
  end
end
