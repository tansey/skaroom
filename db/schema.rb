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

ActiveRecord::Schema.define(version: 20131204193944) do

  create_table "queued_songs", force: true do |t|
    t.integer  "rudy_id"
    t.integer  "song_id"
    t.integer  "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "queued_songs", ["rudy_id"], name: "index_queued_songs_on_rudy_id", using: :btree
  add_index "queued_songs", ["song_id"], name: "index_queued_songs_on_song_id", using: :btree

  create_table "rudies", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "location"
    t.date     "birthdate"
    t.string   "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points",                 default: 0
    t.string   "actual_name"
    t.string   "nickname"
  end

  add_index "rudies", ["email"], name: "index_rudies_on_email", unique: true, using: :btree
  add_index "rudies", ["reset_password_token"], name: "index_rudies_on_reset_password_token", unique: true, using: :btree

  create_table "songs", force: true do |t|
    t.string   "artist"
    t.string   "title"
    t.float    "duration"
    t.string   "song"
    t.integer  "rudy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points",     default: 0
  end

end
