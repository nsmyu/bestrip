require 'faker'

Post.find(1).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(2).id,
      created_at: Post.find(1).created_at.since(2.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(3).id,
      parent_id: 1,
      created_at: Post.find(1).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
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
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(7).id,
      created_at: Post.find(1).created_at.since(2.days),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(5).id,
      created_at: Post.find(1).created_at.since(16.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
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
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(10).id,
      created_at: Post.find(1).created_at.since(1.days),
    },
  ]
)
Post.find(2).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(9).id,
      created_at: Post.find(2).created_at.since(6.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(4).id,
      parent_id: 10,
      created_at: Post.find(2).created_at.since(10.hours),
    },
  ]
)
Post.find(4).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(3).id,
      created_at: Post.find(4).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(1).id,
      created_at: Post.find(4).created_at.since(2.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(10).id,
      created_at: Post.find(4).created_at.since(3.hours),
    },
  ]
)
Post.find(6).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 5),
      user_id: User.find(2).id,
      created_at: Post.find(6).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(5).id,
      parent_id: 15,
      created_at: Post.find(6).created_at.since(14.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(8).id,
      created_at: Post.find(6).created_at.since(7.hours),
    },
  ]
)
Post.find(7).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(4).id,
      created_at: Post.find(7).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(2).id,
      parent_id: 18,
      created_at: Post.find(7).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 4),
      user_id: User.find(8).id,
      created_at: Post.find(7).created_at.since(7.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(2).id,
      parent_id: 20,
      created_at: Post.find(7).created_at.since(15.hours),
    },
  ]
)
Post.find(8).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(6).id,
      created_at: Post.find(8).created_at.since(1.hours),
    },
  ]
)
Post.find(9).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(3).id,
      created_at: Post.find(9).created_at.since(2.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(2).id,
      parent_id: 23,
      created_at: Post.find(9).created_at.since(4.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(6).id,
      created_at: Post.find(9).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(2).id,
      parent_id: 25,
      created_at: Post.find(9).created_at.since(4.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 4),
      user_id: User.find(5).id,
      created_at: Post.find(9).created_at.since(6.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(2).id,
      parent_id: 27,
      created_at: Post.find(9).created_at.since(7.hours),
    },
  ]
)
Post.find(10).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(5).id,
      created_at: Post.find(10).created_at.since(5.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(9).id,
      created_at: Post.find(10).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(6).id,
      created_at: Post.find(10).created_at.since(6.hours),
    },
  ]
)
Post.find(11).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(8).id,
      created_at: Post.find(11).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(10).id,
      created_at: Post.find(11).created_at.since(3.hours),
    },
  ]
)
Post.find(12).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(4).id,
      created_at: Post.find(12).created_at.since(5.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(9).id,
      created_at: Post.find(12).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(1).id,
      created_at: Post.find(12).created_at.since(6.hours),
    },
  ]
)
Post.find(14).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(9).id,
      created_at: Post.find(14).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(3).id,
      parent_id: 37,
      created_at: Post.find(14).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(5).id,
      created_at: Post.find(14).created_at.since(7.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(3).id,
      parent_id: 39,
      created_at: Post.find(14).created_at.since(2.days),
    },
  ]
)
Post.find(15).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(7).id,
      created_at: Post.find(15).created_at.since(2.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(9).id,
      parent_id: 41,
      created_at: Post.find(15).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(7).id,
      parent_id: 41,
      created_at: Post.find(15).created_at.since(4.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(9).id,
      parent_id: 41,
      created_at: Post.find(15).created_at.since(6.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(8).id,
      created_at: Post.find(15).created_at.since(30.minutes),
    },
  ]
)
Post.find(16).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(3).id,
      created_at: Post.find(16).created_at.since(1.hours),
    },
  ]
)
Post.find(17).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(2).id,
      created_at: Post.find(17).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(4).id,
      parent_id: 47,
      created_at: Post.find(17).created_at.since(5.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(3).id,
      created_at: Post.find(17).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(4).id,
      parent_id: 49,
      created_at: Post.find(17).created_at.since(5.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(8).id,
      created_at: Post.find(17).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(3).id,
      parent_id: 51,
      created_at: Post.find(17).created_at.since(2.hours),
    },
  ]
)
Post.find(18).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(6).id,
      created_at: Post.find(18).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(3).id,
      created_at: Post.find(18).created_at.since(1.hours),
    },
  ]
)
Post.find(19).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(8).id,
      created_at: Post.find(19).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(4).id,
      parent_id: 55,
      created_at: Post.find(19).created_at.since(4.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(1).id,
      created_at: Post.find(19).created_at.since(1.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(4).id,
      parent_id: 57,
      created_at: Post.find(19).created_at.since(1.hours),
    },
  ]
)
Post.find(21).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(8).id,
      created_at: Post.find(21).created_at.since(3.hours),
    },
  ]
)
Post.find(22).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(7).id,
      created_at: Post.find(22).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(1).id,
      created_at: Post.find(22).created_at.since(4.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(3).id,
      created_at: Post.find(22).created_at.since(5.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(9).id,
      created_at: Post.find(22).created_at.since(6.hours),
    },
  ]
)
Post.find(23).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(2).id,
      created_at: Post.find(23).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(5).id,
      parent_id: 64,
      created_at: Post.find(23).created_at.since(4.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 1),
      user_id: User.find(1).id,
      created_at: Post.find(23).created_at.since(2.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(5).id,
      parent_id: 66,
      created_at: Post.find(23).created_at.since(3.hours),
    },
  ]
)
Post.find(24).comments.create!(
  [
    {
      content: Faker::Lorem.paragraph(sentence_count: 2),
      user_id: User.find(10).id,
      created_at: Post.find(24).created_at.since(3.hours),
    },
    {
      content: Faker::Lorem.paragraph(sentence_count: 3),
      user_id: User.find(1).id,
      created_at: Post.find(24).created_at.since(4.hours),
    },
  ]
)
