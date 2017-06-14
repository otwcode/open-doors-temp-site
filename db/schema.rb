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

  create_table "archive_configs", id: :integer, default: 0, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "key",             limit: 45,                      null: false
    t.string  "name"
    t.string  "fandom"
    t.text    "stories_note",    limit: 65535
    t.text    "bookmarks_note",  limit: 65535
    t.boolean "send_email",                    default: false,   null: false
    t.boolean "post_preview",                  default: false,   null: false
    t.integer "items_per_page",                default: 30,      null: false
    t.string  "archivist",                     default: "testy", null: false
    t.string  "collection_name"
    t.integer "imported",                      default: 0
    t.integer "not_imported",                  default: 0
    t.index ["id"], name: "id_UNIQUE", unique: true, using: :btree
    t.index ["key"], name: "key_UNIQUE", unique: true, using: :btree
  end

  create_table "audits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes", limit: 65535
    t.integer  "version",                       default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "authors", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",          default: "",    null: false
    t.string  "email",         default: "",    null: false
    t.boolean "imported",      default: false, null: false
    t.boolean "do_not_import", default: false, null: false
    t.boolean "to_delete",     default: false
    t.index ["id"], name: "id_UNIQUE", unique: true, using: :btree
  end

  create_table "chapters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "position"
    t.string   "title",                      default: "", null: false
    t.integer  "author_id",                  default: 0,  null: false
    t.text     "text",      limit: 16777215
    t.datetime "date"
    t.integer  "story_id",                   default: 0
    t.text     "notes",     limit: 65535
    t.string   "url",       limit: 1024
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
    t.boolean  "do_not_import",               default: false, null: false
    t.string   "ao3_url"
    t.string   "import_notes",  limit: 1024,  default: ""
    t.string   "coauthor_id",   limit: 45,    default: "0"
    t.index ["author_id"], name: "authorId", using: :btree
  end

  create_table "story_links", id: :integer, default: 0, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
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
    t.boolean  "do_not_import",               default: false, null: false
    t.string   "ao3_url"
    t.boolean  "broken_link",                 default: false, null: false
    t.string   "import_notes",  limit: 1024,  default: ""
    t.index ["author_id"], name: "authorId", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
