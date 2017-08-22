# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170821190326) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "playlists", force: true do |t|
    t.integer  "user_id"
    t.string   "api_playlist_id"
    t.string   "api_title"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "api_item_count"
    t.integer  "playlist_items_count", default: 0
  end

  create_table "roles", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "show_versions", force: true do |t|
    t.integer  "show_id"
    t.integer  "version"
    t.date     "air_date"
    t.string   "title"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "show_versions", ["show_id"], name: "index_show_versions_on_show_id", using: :btree

  create_table "shows", force: true do |t|
    t.date     "air_date"
    t.string   "title"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer  "version"
    t.string   "hosts"
  end

  create_table "user_versions", force: true do |t|
    t.integer  "user_id"
    t.integer  "version"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "profile_image"
    t.string   "auth_hash"
    t.integer  "expires_at",    limit: 8
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "user_versions", ["user_id"], name: "index_user_versions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "profile_image"
    t.string   "auth_hash"
    t.integer  "expires_at",          limit: 8
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.datetime "deleted_at"
    t.integer  "version"
    t.string   "encrypted_password",            default: "",    null: false
    t.integer  "sign_in_count",                 default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "requires_auth",                 default: true
    t.boolean  "importing_playlists",           default: false
    t.string   "refresh_token"
  end

  create_table "video_versions", force: true do |t|
    t.integer  "video_id"
    t.integer  "version"
    t.integer  "show_id"
    t.string   "title"
    t.text     "link"
    t.string   "start_time"
    t.string   "end_time"
    t.integer  "sort_order"
    t.string   "api_video_id"
    t.string   "api_published_at"
    t.string   "api_channel_id"
    t.string   "api_channel_title"
    t.text     "api_description"
    t.string   "api_thumbnail_medium_url"
    t.string   "api_thumbnail_default_url"
    t.string   "api_thumbnail_high_url"
    t.string   "api_title"
    t.string   "api_duration"
    t.integer  "api_duration_seconds"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "video_versions", ["video_id"], name: "index_video_versions_on_video_id", using: :btree

  create_table "videos", force: true do |t|
    t.integer  "parent_id"
    t.string   "title"
    t.text     "link"
    t.string   "start_time"
    t.string   "end_time"
    t.integer  "sort_order"
    t.string   "api_video_id"
    t.string   "api_published_at"
    t.string   "api_channel_id"
    t.string   "api_channel_title"
    t.text     "api_description"
    t.string   "api_thumbnail_medium_url"
    t.string   "api_thumbnail_default_url"
    t.string   "api_thumbnail_high_url"
    t.string   "api_title"
    t.string   "api_duration"
    t.integer  "api_duration_seconds"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "deleted_at"
    t.integer  "version"
    t.string   "parent_type"
  end

end
