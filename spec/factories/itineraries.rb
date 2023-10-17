FactoryBot.define do
  factory :itinerary do
    sequence(:title)  { |n| "Trip #{n}" }
    departure_date    { "2024-02-01" }
    return_date       { "2024-02-08" }
    owner

    after(:build) do |itinerary|
      itinerary.members << itinerary.owner
    end

    trait :with_schedule do
      after(:build) do |itinerary|
        itinerary.schedules << build(:schedule)
      end
    end
  end
end
