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

ActiveRecord::Schema[7.2].define(version: 2024_11_27_072531) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cells", primary_key: "cell_id", id: :serial, force: :cascade do |t|
    t.string "cell_loc", null: false
    t.float "mons_prob"
    t.float "disaster_prob"
    t.string "weather", null: false
    t.string "terrain", null: false
    t.boolean "has_store", null: false
    t.integer "grid_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cell_id"], name: "index_cells_on_cell_id", unique: true
  end

  create_table "characters", primary_key: "character_name", id: :string, force: :cascade do |t|
    t.string "username", null: false
    t.integer "health", null: false
    t.integer "experience", null: false
    t.integer "level", null: false
    t.integer "grid_id", null: false
    t.integer "cell_id", null: false
    t.integer "inv_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grids", primary_key: "grid_id", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventories", primary_key: "inv_id", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "items", default: [], array: true
    t.index ["inv_id"], name: "index_inventories_on_inv_id", unique: true
  end

  create_table "items", primary_key: "item_id", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.integer "cost", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_items_on_item_id", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.string "username", null: false
    t.bigint "world_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["world_id"], name: "index_messages_on_world_id"
  end

  create_table "user_grid_visibilities", force: :cascade do |t|
    t.string "username", null: false
    t.integer "grid_id", null: false
    t.integer "visibility", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username", "grid_id"], name: "index_user_grid_visibilities_on_username_and_grid_id", unique: true
  end

  create_table "users", primary_key: "username", id: :string, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "shard_balance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "world_players", id: false, force: :cascade do |t|
    t.string "username", null: false
    t.integer "grid_id", null: false
    t.bigint "world_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username", "grid_id"], name: "index_world_players_on_username_and_grid_id", unique: true
    t.index ["world_id"], name: "index_world_players_on_world_id"
  end

  create_table "worlds", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "grid_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grid_id"], name: "index_worlds_on_grid_id"
  end

  add_foreign_key "cells", "grids", primary_key: "grid_id"
  add_foreign_key "characters", "cells", primary_key: "cell_id"
  add_foreign_key "characters", "grids", primary_key: "grid_id"
  add_foreign_key "characters", "inventories", column: "inv_id", primary_key: "inv_id"
  add_foreign_key "characters", "users", column: "username", primary_key: "username"
  add_foreign_key "messages", "users", column: "username", primary_key: "username"
  add_foreign_key "messages", "worlds"
  add_foreign_key "user_grid_visibilities", "grids", primary_key: "grid_id"
  add_foreign_key "user_grid_visibilities", "users", column: "username", primary_key: "username"
  add_foreign_key "world_players", "grids", primary_key: "grid_id"
  add_foreign_key "world_players", "users", column: "username", primary_key: "username"
  add_foreign_key "world_players", "worlds"
  add_foreign_key "worlds", "grids", primary_key: "grid_id"
end
