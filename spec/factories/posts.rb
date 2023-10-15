FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post_#{n}" }
    caption { "One of the best trips of my life!" }
    itinerary
    user

    trait :with_photo do
      after(:build) do |post|
        post.photos << build(:photo)
      end
    end
  end
end
