FactoryBot.define do
  factory :post do
    title { "MyString" }
    photos { "" }
    caption { "MyText" }
    itinerary_users { nil }
  end
end
