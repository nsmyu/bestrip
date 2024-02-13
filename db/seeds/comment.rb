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
      user_id: User.find(3).id,
      parent_id: 1,
      created_at: Post.find(1).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: Post.find(1).user.id,
      parent_id: 1,
      created_at: Post.find(1).created_at.since(4.hours),
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
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(5).id,
      created_at: Post.find(1).created_at.since(16.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: Post.find(8).user.id,
      parent_id: 6,
      created_at: Post.find(1).created_at.since(18.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: Post.find(1).user.id,
      parent_id: 6,
      created_at: Post.find(1).created_at.since(19.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(10).id,
      created_at: Post.find(1).created_at.since(1.days),
    },
  ]
)

Post.find(15).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(7).id,
      created_at: Post.find(15).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(9).id,
      parent_id: 10,
      created_at: Post.find(15).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(7).id,
      parent_id: 10,
      created_at: Post.find(15).created_at.since(4.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(9).id,
      parent_id: 10,
      created_at: Post.find(15).created_at.since(26.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(8).id,
      created_at: Post.find(15).created_at.since(30.minutes),
    },
  ]
)
