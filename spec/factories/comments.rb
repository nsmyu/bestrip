FactoryBot.define do
  factory :comment do
    user
    post
    content { Faker::Lorem.paragraph(sentence_count: 3) }
  end
end
