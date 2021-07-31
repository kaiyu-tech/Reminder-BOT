# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_25_124341) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.time "start_time", precision: 6
    t.time "end_time", precision: 6
    t.integer "day_of_week"
    t.integer "with_order"
    t.integer "week_of_month"
    t.integer "day_of_month"
    t.datetime "start_datetime", precision: 6, null: false
    t.datetime "end_datetime", precision: 6, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.integer "number", default: 0, null: false
    t.integer "unit", default: 0, null: false
    t.datetime "remind_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_reminders_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "line_id_digest", null: false
    t.string "line_name", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "activate", default: false, null: false
    t.datetime "expires_in", precision: 6
    t.string "notify_token_encrypt"
    t.datetime "reminded_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_id_digest"], name: "index_users_on_line_id_digest", unique: true
  end

  add_foreign_key "events", "users"
  add_foreign_key "reminders", "events"
end
