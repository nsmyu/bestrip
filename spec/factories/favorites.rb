FactoryBot.define do
  factory :favorite do
    sequence(:place_id) { |n| "place_id_#{n}" }
    user
  end
end
