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

ActiveRecord::Schema.define(version: 2018_09_12_181312) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cookie_recipes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "emoji"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name"
    t.string "emoji"
  end

  create_table "owned_cookies", id: :serial, force: :cascade do |t|
    t.integer "owner_id"
    t.integer "cookie_recipe_id"
    t.integer "giveable_count"
    t.integer "received_count"
  end

  create_table "owned_ingredients", force: :cascade do |t|
    t.integer "owner_id"
    t.integer "ingredient_id"
    t.integer "giveable_count"
    t.integer "received_count"
  end

  create_table "owners", id: :serial, force: :cascade do |t|
    t.string "slack_id"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.integer "cookie_recipe_id"
    t.integer "ingredient_id"
    t.integer "count"
  end

end
