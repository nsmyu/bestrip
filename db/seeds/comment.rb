require 'faker'

Post.find(1).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(2).id,
      created_at: Post.find(1).created_at.since(2.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(9).id,
      created_at: Post.find(1).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(7).id,
      created_at: Post.find(1).created_at.since(2.days),
    },
  ]
)
