FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post of Trip_#{n}" }
    caption { "The trip was great! #bestrip" }
    itinerary_public { "true" }
    itinerary
    user { itinerary.owner if itinerary }

    trait :with_caption_awesome do
      caption { "The trip was awesome! #bestrip" }
    end

    trait :with_photo do
      after(:build) do |post|
        post.photos << build(:photo)
      end
    end
  end
end
