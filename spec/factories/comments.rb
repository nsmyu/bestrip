FactoryBot.define do
  factory :comment do
    user
    post
    content { "Looks amazing!" }
  end
end
