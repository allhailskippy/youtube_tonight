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

ActiveRecord::Schema.define(version: 20170908003451) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
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

  create_table "playlists", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "api_playlist_id"
    t.string   "api_title"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "video_count",                   default: 0
    t.text     "api_description"
    t.string   "api_thumbnail_default_url"
    t.integer  "api_thumbnail_default_width"
    t.integer  "api_thumbnail_default_height"
    t.string   "api_thumbnail_medium_url"
    t.integer  "api_thumbnail_medium_width"
    t.integer  "api_thumbnail_medium_height"
    t.string   "api_thumbnail_high_url"
    t.integer  "api_thumbnail_high_width"
    t.integer  "api_thumbnail_high_height"
    t.string   "api_thumbnail_standard_url"
    t.integer  "api_thumbnail_standard_width"
    t.integer  "api_thumbnail_standard_height"
    t.string   "api_thumbnail_maxres_url"
    t.integer  "api_thumbnail_maxres_width"
    t.integer  "api_thumbnail_maxres_height"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "show_users", force: :cascade do |t|
    t.integer  "show_id"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shows", force: :cascade do |t|
    t.date     "air_date"
    t.string   "title"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "profile_image"
    t.string   "auth_hash"
    t.integer  "expires_at",          limit: 8
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
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

  create_table "videos", force: :cascade do |t|
    t.integer  "parent_id"
    t.string   "title"
    t.text     "link"
    t.string   "start_time"
    t.string   "end_time"
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
    t.string   "parent_type"
    t.integer  "position"
  end

end
