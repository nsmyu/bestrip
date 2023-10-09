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

ActiveRecord::Schema[7.0].define(version: 2023_10_09_094143) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "favorites", force: :cascade do |t|
    t.string "place_id", null: false
    t.bigint "itinerary_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itinerary_id"], name: "index_favorites_on_itinerary_id"
    t.index ["place_id", "itinerary_id"], name: "index_favorites_on_place_id_and_itinerary_id", unique: true
  end

  create_table "itineraries", force: :cascade do |t|
    t.string "title", null: false
    t.string "image"
    t.date "departure_date", null: false
    t.date "return_date", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title", "user_id"], name: "index_itineraries_on_title_and_user_id", unique: true
  end

  create_table "itinerary_users", force: :cascade do |t|
    t.bigint "itinerary_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itinerary_id"], name: "index_itinerary_users_on_itinerary_id"
    t.index ["user_id"], name: "index_itinerary_users_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.json "photos", null: false
    t.text "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "itinerary_id", null: false
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
    t.date "schedule_date"
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
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false
    t.index ["bestrip_id"], name: "index_users_on_bestrip_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "favorites", "itineraries"
  add_foreign_key "itinerary_users", "itineraries"
  add_foreign_key "itinerary_users", "users"
  add_foreign_key "posts", "itineraries"
  add_foreign_key "posts", "users"
  add_foreign_key "schedules", "itineraries"
end
