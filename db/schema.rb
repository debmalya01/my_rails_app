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

ActiveRecord::Schema[7.1].define(version: 2025_06_30_092031) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "booking_services", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "service_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_services_on_booking_id"
    t.index ["service_type_id"], name: "index_booking_services_on_service_type_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.date "service_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "service_center_id", null: false
    t.string "pincode"
    t.index ["car_id"], name: "index_bookings_on_car_id"
    t.index ["service_center_id"], name: "index_bookings_on_service_center_id"
  end

  create_table "cars", force: :cascade do |t|
    t.string "make"
    t.string "model"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_name"
    t.string "registration_number"
  end

  create_table "service_centers", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pincode"
  end

  create_table "service_types", force: :cascade do |t|
    t.string "name"
    t.decimal "base_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "booking_services", "bookings"
  add_foreign_key "booking_services", "service_types"
  add_foreign_key "bookings", "cars"
  add_foreign_key "bookings", "service_centers"
end
