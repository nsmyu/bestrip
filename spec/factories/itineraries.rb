FactoryBot.define do
  factory :itinerary do
    title          { "Trip to Sydney" }
    departure_date { "2024-02-01" }
    return_date    { "2024-02-08" }
    owner

    trait :other do
      title          { "Trip to Okinawa" }
      departure_date { "2024-03-01" }
      return_date    { "2024-03-04" }
    end
  end
end
