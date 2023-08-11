# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!(
  name: "Luke",
  bestrip_id: "luke_id",
  email: "star_wars@example.com",
  avatar: File.open("./app/assets/images/avatar/luke.jpg"),
  introduction: Faker::Movies::StarWars.quote(character: "luke_skywalker"),
  password: "password",
  password_confirmation: "password",
)
