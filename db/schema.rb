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

ActiveRecord::Schema[8.0].define(version: 2025_05_31_164856) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "allergens", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "restaurant_id"
    t.index ["restaurant_id"], name: "index_allergens_on_restaurant_id"
  end

  create_table "allergens_dishes", force: :cascade do |t|
    t.bigint "allergen_id", null: false
    t.bigint "dish_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allergen_id"], name: "index_allergens_dishes_on_allergen_id"
    t.index ["dish_id"], name: "index_allergens_dishes_on_dish_id"
  end

  create_table "allergens_drinks", force: :cascade do |t|
    t.bigint "allergen_id", null: false
    t.bigint "drink_id", null: false
    t.index ["allergen_id", "drink_id"], name: "index_allergens_drinks_on_allergen_id_and_drink_id", unique: true
    t.index ["allergen_id"], name: "index_allergens_drinks_on_allergen_id"
    t.index ["drink_id"], name: "index_allergens_drinks_on_drink_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_type"
    t.bigint "restaurant_id"
    t.integer "position"
    t.index ["restaurant_id"], name: "index_categories_on_restaurant_id"
  end

  create_table "dishes", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
    t.float "prize"
    t.integer "category_id"
    t.boolean "lock", default: false
    t.bigint "special_menu_id"
    t.boolean "per_gram", default: false
    t.boolean "per_kilo", default: false
    t.boolean "per_unit", default: false
    t.bigint "restaurant_id"
    t.string "dietary_labels", default: [], array: true
    t.index ["dietary_labels"], name: "index_dishes_on_dietary_labels", using: :gin
    t.index ["restaurant_id"], name: "index_dishes_on_restaurant_id"
    t.index ["special_menu_id"], name: "index_dishes_on_special_menu_id"
  end

  create_table "drinks", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "active", default: true
    t.boolean "lock", default: false
    t.bigint "category_id"
    t.bigint "restaurant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.decimal "measure", precision: 10, scale: 2
    t.string "unit"
    t.index ["category_id"], name: "index_drinks_on_category_id"
    t.index ["restaurant_id"], name: "index_drinks_on_restaurant_id"
  end

  create_table "mobility_string_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.string "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_string_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_string_translations_on_keys", unique: true
    t.index ["translatable_type", "key", "value", "locale"], name: "index_mobility_string_translations_on_query_keys"
  end

  create_table "mobility_text_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.text "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_text_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_text_translations_on_keys", unique: true
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "address"
    t.string "phone"
    t.text "description"
    t.string "province"
    t.string "city"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_restaurants_on_confirmation_token", unique: true
    t.index ["email"], name: "index_restaurants_on_email", unique: true
    t.index ["reset_password_token"], name: "index_restaurants_on_reset_password_token", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "use_menu_path", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "show_toggler", default: true
    t.string "root_page", default: "index"
    t.decimal "menu_price", default: "12.5"
    t.boolean "locale_toggler", default: false
    t.bigint "restaurant_id"
    t.index ["restaurant_id"], name: "index_settings_on_restaurant_id"
  end

  create_table "special_menus", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.bigint "restaurant_id"
    t.index ["restaurant_id"], name: "index_special_menus_on_restaurant_id"
  end

  create_table "wine_origin_denominations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "restaurant_id"
    t.index ["restaurant_id"], name: "index_wine_origin_denominations_on_restaurant_id"
  end

  create_table "wine_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wines", force: :cascade do |t|
    t.string "name"
    t.string "wine_type"
    t.text "description"
    t.decimal "price"
    t.bigint "wine_origin_denomination_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price_per_glass"
    t.boolean "active", default: true
    t.boolean "lock", default: false
    t.bigint "restaurant_id"
    t.index ["restaurant_id"], name: "index_wines_on_restaurant_id"
    t.index ["wine_origin_denomination_id"], name: "index_wines_on_wine_origin_denomination_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allergens", "restaurants"
  add_foreign_key "allergens_dishes", "allergens"
  add_foreign_key "allergens_dishes", "dishes"
  add_foreign_key "allergens_drinks", "allergens"
  add_foreign_key "allergens_drinks", "drinks"
  add_foreign_key "categories", "restaurants"
  add_foreign_key "dishes", "restaurants"
  add_foreign_key "dishes", "special_menus"
  add_foreign_key "drinks", "categories"
  add_foreign_key "drinks", "restaurants"
  add_foreign_key "settings", "restaurants"
  add_foreign_key "special_menus", "restaurants"
  add_foreign_key "wine_origin_denominations", "restaurants"
  add_foreign_key "wines", "restaurants"
  add_foreign_key "wines", "wine_origin_denominations"
end
