require 'faker'

10.times do |n|
  random_pass = SecureRandom.base36
  User.create!(
    name: Faker::Name.first_name,
    bestrip_id: "user_#{n+1}_id",
    email: "email_#{n+1}@example.com",
    avatar: File.open("./app/assets/images/avatar/avatar_#{n+1}.jpg"),
    introduction: Faker::Lorem.paragraph(sentence_count: 8),
    password: random_pass,
    password_confirmation: random_pass,
  )
end
