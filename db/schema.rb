# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190114183126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", id: :serial, force: :cascade do |t|
    t.integer "race_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category"
    t.index ["race_id"], name: "index_categories_on_race_id"
  end

  create_table "club_league_points", force: :cascade do |t|
    t.bigint "club_id"
    t.bigint "league_id"
    t.jsonb "points", default: {}
    t.integer "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_club_league_points_on_club_id"
    t.index ["league_id"], name: "index_club_league_points_on_league_id"
  end

  create_table "clubs", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category", default: 0
    t.index ["user_id"], name: "index_clubs_on_user_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "league_type"
    t.string "slug"
    t.index ["slug"], name: "index_leagues_on_slug", unique: true
  end

  create_table "pools", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "race_admins", force: :cascade do |t|
    t.bigint "racer_id"
    t.bigint "race_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_race_admins_on_race_id"
    t.index ["racer_id"], name: "index_race_admins_on_racer_id"
  end

  create_table "race_results", id: :serial, force: :cascade do |t|
    t.integer "racer_id"
    t.integer "race_id"
    t.integer "status"
    t.jsonb "lap_times", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "points"
    t.integer "category_id"
    t.integer "position"
    t.integer "start_number_id"
    t.integer "signal_strength", default: -1000, null: false
    t.datetime "started_at"
    t.jsonb "climbs", default: {}
    t.string "finish_delta", default: "- -"
    t.string "finish_time", default: "- -"
    t.integer "additional_points"
    t.integer "missed_control_points", default: 0
    t.index ["category_id"], name: "index_race_results_on_category_id"
    t.index ["race_id"], name: "index_race_results_on_race_id"
    t.index ["racer_id"], name: "index_race_results_on_racer_id"
    t.index ["start_number_id"], name: "index_race_results_on_start_number_id"
  end

  create_table "racers", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "year_of_birth"
    t.integer "gender"
    t.string "email"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "club_id"
    t.integer "category"
    t.string "address"
    t.string "zip_code"
    t.string "town"
    t.integer "day_of_birth"
    t.integer "month_of_birth"
    t.string "shirt_size"
    t.string "personal_best"
    t.string "country"
    t.string "uci_id"
    t.index ["club_id"], name: "index_racers_on_club_id"
    t.index ["user_id"], name: "index_racers_on_user_id"
  end

  create_table "races", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "date"
    t.integer "laps"
    t.integer "easy_laps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "description_url"
    t.datetime "registration_threshold"
    t.text "email_body"
    t.boolean "lock_race_results"
    t.boolean "send_email"
    t.boolean "uci_display"
    t.integer "race_type", default: 0
    t.bigint "pool_id"
    t.bigint "league_id"
    t.jsonb "control_points", array: true
    t.index ["league_id"], name: "index_races_on_league_id"
    t.index ["pool_id"], name: "index_races_on_pool_id"
  end

  create_table "start_numbers", id: :serial, force: :cascade do |t|
    t.string "value"
    t.string "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "race_id"
    t.bigint "pool_id"
    t.string "alternate_tag_id"
    t.index ["pool_id"], name: "index_start_numbers_on_pool_id"
    t.index ["race_id"], name: "index_start_numbers_on_race_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "categories", "races"
  add_foreign_key "club_league_points", "clubs"
  add_foreign_key "club_league_points", "leagues"
  add_foreign_key "clubs", "users"
  add_foreign_key "race_admins", "racers"
  add_foreign_key "race_admins", "races"
  add_foreign_key "race_results", "racers"
  add_foreign_key "race_results", "races"
  add_foreign_key "racers", "clubs"
  add_foreign_key "racers", "users"
  add_foreign_key "races", "leagues"
  add_foreign_key "races", "pools"
  add_foreign_key "start_numbers", "pools"
  add_foreign_key "start_numbers", "races"
end
