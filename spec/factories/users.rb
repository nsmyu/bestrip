FactoryBot.define do
  factory :user, aliases: [:owner] do
    name     { "Conan" }
    email    { "edogawa@example.com" }
    password { "password" }
    password_confirmation { "password" }

    trait :other do
      name  { "Ran" }
      email { "Mouri@example.com" }
    end
  end
end
