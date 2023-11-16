FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post of Trip_#{n}" }
    itinerary_public { "true" }
    itinerary
    user { itinerary.owner if itinerary }

    trait :caption_great_with_hashtag do
      caption { "The trip was great! #bestrip" }
    end

    trait :caption_awesome_no_hashtag do
      caption { "The trip was awesome!" }
    end

    trait :with_photo do
      after(:build) do |post|
        post.photos << build(:photo)
      end
    end
  end
end
