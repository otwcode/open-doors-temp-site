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

ActiveRecord::Schema.define(version: 0) do

  create_table :archive_configs, id: :integer, default: 0, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "key", limit: 45, null: false
    t.string "name", limit: 255
    t.string "fandom", limit: 255
    t.text "stories_note", limit: 65535
    t.text "bookmarks_note", limit: 65535
    t.boolean "send_email", default: false, null: false
    t.boolean "post_preview", default: false, null: false
    t.integer "items_per_page", default: 30, null: false
    t.string "archivist", limit: 255, default: "testy", null: false
    t.string "collection_name", limit: 255
    t.integer "imported", default: 0
    t.integer "not_imported", default: 0
    t.index ["id"], name: "id_UNIQUE", unique: true, using: :btree
    t.index ["key"], name: "key_UNIQUE", unique: true, using: :btree
  end

  create_table "authors", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",        default: "",    null: false
    t.string  "email",       default: "",    null: false
    t.boolean "imported",    default: false, null: false
    t.boolean "do_not_import", default: false, null: false
    t.boolean "to_delete",    default: false
    t.index ["id"], name: "id_UNIQUE", unique: true, using: :btree
  end

  create_table "bookmarks", id: :integer, default: 0, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title",                       default: "",    null: false
    t.text     "summary",       limit: 65535
    t.text     "notes",         limit: 65535
    t.integer  "author_id",                   default: 0
    t.string   "rating",                      default: "",    null: false
    t.date     "date",                                        null: false
    t.datetime "updated"
    t.string   "categories",    limit: 45
    t.string   "tags",                        default: "",    null: false
    t.string   "warnings",                    default: ""
    t.string   "fandoms"
    t.string   "characters"
    t.string   "relationships"
    t.string   "url"
    t.boolean  "imported",                    default: false, null: false
    t.boolean  "do_not_import",                 default: false, null: false
    t.string   "ao3_url"
    t.boolean  "broken_link",                  default: false, null: false
    t.string   "import_notes",   limit: 1024,  default: ""
    t.index ["author_id"], name: "authorId", using: :btree
  end

  create_table "chapters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer   "position"
    t.string   "title",                     default: "", null: false
    t.integer  "author_id",                  default: 0,  null: false
    t.text     "text",     limit: 16777215
    t.datetime "date"
    t.integer  "story_id",                  default: 0
    t.text     "notes",    limit: 65535
    t.string   "url",      limit: 1024
    t.index ["id"], name: "id_UNIQUE", unique: true, using: :btree
    t.index ["story_id"], name: "storyid", using: :btree
  end

  create_table "stories", id: :integer, default: 0, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title",                       default: "",    null: false
    t.text     "summary",       limit: 65535
    t.text     "notes",         limit: 65535
    t.integer  "author_id",                   default: 0
    t.string   "rating",                      default: "",    null: false
    t.datetime "date"
    t.datetime "updated"
    t.string   "categories",    limit: 45
    t.string   "tags",                        default: "",    null: false
    t.string   "warnings",                    default: ""
    t.string   "fandoms"
    t.string   "characters"
    t.string   "relationships"
    t.string   "url"
    t.boolean  "imported",                    default: false, null: false
    t.boolean  "do_not_import",                 default: false, null: false
    t.string   "ao3_url"
    t.string   "import_notes",   limit: 1024,  default: ""
    t.string   "coauthor_id",   limit: 45,    default: "0"
    t.index ["author_id"], name: "authorId", using: :btree
  end

end
