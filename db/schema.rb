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

ActiveRecord::Schema.define(version: 20160926071533) do

  create_table "actual_texts", force: :cascade do |t|
    t.string   "URL",         limit: 255
    t.integer  "strip_start"
    t.integer  "strip_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "what",        limit: 255
  end

  create_table "author_texts", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "text_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "year_of_birth"
    t.integer  "year_of_death"
    t.string   "where",         limit: 255
    t.text     "about"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "english_name",  limit: 255
    t.string   "date_of_birth", limit: 255
    t.string   "when_died",     limit: 255
  end

  create_table "dictionaries", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.string   "long_title",     limit: 255
    t.string   "URI",            limit: 255
    t.string   "current_editor", limit: 255
    t.string   "contact",        limit: 255
    t.string   "organisation",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "machine",                    default: false
  end

  create_table "entries", force: :cascade do |t|
    t.integer  "dictionary_id"
    t.string   "label",         limit: 255
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fyles", force: :cascade do |t|
    t.string   "URL",              limit: 255
    t.string   "what",             limit: 255
    t.integer  "strip_start"
    t.integer  "strip_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_negotiation", limit: 255
    t.boolean  "handled",                      default: false
    t.integer  "status_code"
    t.string   "cache_file",       limit: 255
    t.string   "encoding",         limit: 255
    t.string   "local_file",       limit: 255
  end

  add_index "fyles", ["URL"], name: "index_fyles_on_URL", unique: true

  create_table "http_request_loggers", force: :cascade do |t|
    t.string   "caller",     limit: 255
    t.string   "uri",        limit: 255
    t.string   "request",    limit: 255
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", force: :cascade do |t|
    t.string   "table_name",  limit: 255
    t.integer  "row_id"
    t.string   "IRI",         limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", force: :cascade do |t|
    t.string   "URI",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "texts", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.integer  "original_year"
    t.integer  "edition_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_in_english",   limit: 255
    t.integer  "fyle_id"
    t.boolean  "include",                       default: false
    t.string   "original_language", limit: 255
  end

  add_index "texts", ["name_in_english", "original_year"], name: "index_texts_on_name_in_english_and_original_year", unique: true

  create_table "units", force: :cascade do |t|
    t.integer  "dictionary_id"
    t.string   "entry",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "normal_form"
    t.string   "analysis"
    t.boolean  "confirmation",              default: false
    t.string   "what_it_is"
    t.string   "display_name"
  end

  create_table "writings", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "text_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role"
  end

  add_index "writings", ["author_id", "text_id"], name: "index_writings_on_author_id_and_text_id", unique: true

end
