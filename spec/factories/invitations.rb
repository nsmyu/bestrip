FactoryBot.define do
  factory :invitation do
    itinerary
    code { SecureRandom.urlsafe_base64 }

    trait :with_user do
      user
    end
  end
end
