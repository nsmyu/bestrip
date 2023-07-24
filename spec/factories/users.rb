FactoryBot.define do
  factory :user do
    name       { "Conan" }
    email      { "edogawa@example.com" }
    password   { "password1" }
    password_confirmation { "password1" }
  end
end
