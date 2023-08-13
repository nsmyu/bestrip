FactoryBot.define do
  factory :itinerary do
    sequence(:title)  { |n| "Trip #{n}" }
    departure_date    { "2024-02-01" }
    return_date       { "2024-02-08" }
    owner
  end
end
