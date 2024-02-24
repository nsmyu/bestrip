FactoryBot.define do
  factory :pending_invitation do
    itinerary

    trait :with_user_id do
      user
    end

    trait :with_invitation_code do
      invitation_code { SecureRandom.urlsafe_base64 }
    end
  end
end
