FactoryBot.define do
  factory :schedule do
    sequence(:title) { |n| "Schedule_#{n}" }
    itinerary
  end
end
