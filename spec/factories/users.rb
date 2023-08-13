FactoryBot.define do
  factory :user, aliases: [:owner] do
    name     { "Luke" }
    email    { "star_wars_1@example.com" }
    password { "password" }
    password_confirmation { "password" }

    trait :other do
      name  { "Leia" }
      email { "star_wars_2@example.com" }
    end
  end
end
