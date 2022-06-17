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

ActiveRecord::Schema[7.0].define(version: 2022_06_03_124553) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bouquets", force: :cascade do |t|
    t.string "address"
    t.string "number"
    t.string "name"
    t.string "shop_id"
    t.integer "price", default: 0
    t.boolean "sold", default: false
    t.boolean "vitrine", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bouquets_flowers_joins", force: :cascade do |t|
    t.integer "flower_id"
    t.integer "bouquet_id"
    t.integer "counter", default: 1
    t.index ["bouquet_id"], name: "index_bouquets_flowers_joins_on_bouquet_id"
    t.index ["flower_id", "bouquet_id"], name: "post_user_un", unique: true
    t.index ["flower_id"], name: "index_bouquets_flowers_joins_on_flower_id"
  end

  create_table "flowers", force: :cascade do |t|
    t.string "name"
    t.string "flower_id"
    t.integer "price"
    t.string "uuid"
    t.string "code"
    t.string "outCode"
    t.string "ean13"
    t.integer "num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "position"
    t.integer "access"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string "login"
    t.string "name"
    t.string "surname"
    t.string "email"
    t.string "password_digest"
    t.string "id"
    t.string "shop_point"
    t.integer "role_id"
  end

end
