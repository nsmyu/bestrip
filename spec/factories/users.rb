FactoryBot.define do
  factory :user do
    name       { "Conan" }
    bestrip_id { "shinichi" }
    email      { "edogawa@example.com" }
    password   { "password" }
    password_confirmation   { "password" }
  end
end
