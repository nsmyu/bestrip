# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_02_12_220630) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "itineraries", force: :cascade do |t|
    t.string "title", null: false
    t.string "image"
    t.date "departure_date", null: false
    t.date "return_date", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "itinerary_users", force: :cascade do |t|
    t.bigint "itinerary_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itinerary_id"], name: "index_itinerary_users_on_itinerary_id"
    t.index ["user_id"], name: "index_itinerary_users_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_likes_on_post_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "photos", force: :cascade do |t|
    t.string "url", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_photos_on_post_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "place_id", null: false
    t.string "placeable_type", null: false
    t.bigint "placeable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id", "placeable_type", "placeable_id"], name: "index_places_on_place_id_and_placeable_type_and_placeable_id", unique: true
    t.index ["placeable_type", "placeable_id"], name: "index_places_on_placeable"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.text "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "itinerary_id", null: false
    t.boolean "itinerary_public", default: true, null: false
    t.integer "likes_count", default: 0, null: false
    t.index ["itinerary_id"], name: "index_posts_on_itinerary_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string "title", null: false
    t.time "start_at"
    t.time "end_at"
    t.string "icon"
    t.bigint "itinerary_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date"
    t.string "place_id"
    t.text "note"
    t.index ["itinerary_id"], name: "index_schedules_on_itinerary_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "bestrip_id"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "avatar"
    t.text "introduction"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bestrip_id"], name: "index_users_on_bestrip_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "itinerary_users", "itineraries"
  add_foreign_key "itinerary_users", "users"
  add_foreign_key "likes", "posts"
  add_foreign_key "likes", "users"
  add_foreign_key "photos", "posts"
  add_foreign_key "posts", "itineraries"
  add_foreign_key "posts", "users"
  add_foreign_key "schedules", "itineraries"
end
