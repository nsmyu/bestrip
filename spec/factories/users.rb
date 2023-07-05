FactoryBot.define do
  factory :user do
    name       { "Conan" }
    bestrip_id { "shinichi_kudo" }
    email      { "edogawa@example.com" }
    password   { "password1" }
    password_confirmation { "password1" }
  end
end
