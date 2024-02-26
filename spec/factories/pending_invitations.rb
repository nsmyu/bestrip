FactoryBot.define do
  factory :pending_invitation do
    itinerary

    trait :with_user do
      user
    end

    trait :with_code do
      code { SecureRandom.urlsafe_base64 }
    end
  end
end
