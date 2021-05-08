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

  create_table "archive_configs", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", limit: 45, null: false
    t.string "name"
    t.string "fandom"
    t.text "stories_note"
    t.text "bookmarks_note"
    t.boolean "send_email", default: false, null: false
    t.boolean "post_preview", default: false, null: false
    t.string "archivist", limit: 100, default: "testy", null: false
    t.string "collection_name"
    t.string "host", limit: 15, default: "ariana"
    t.index ["id"], name: "id_UNIQUE", unique: true
    t.index ["key"], name: "Key_UNIQUE", unique: true
  end

  create_table "audits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment", limit: 2048
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.boolean "imported", default: false, null: false
    t.boolean "do_not_import", default: false, null: false
    t.boolean "to_delete", default: false
    t.index ["id"], name: "id_UNIQUE", unique: true
  end

  create_table "chapters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "position"
    t.string "title", default: "", null: false
    t.integer "authorID", default: 0, null: false
    t.text "text", limit: 16777215
    t.datetime "date"
    t.integer "story_id", default: 0
    t.text "notes"
    t.string "url", limit: 1024
    t.index ["id"], name: "id_UNIQUE", unique: true
    t.index ["story_id"], name: "storyid"
  end

  create_table "stories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "summary"
    t.text "notes"
    t.integer "author_id", default: 0
    t.string "rating", default: "", null: false
    t.datetime "date"
    t.datetime "updated"
    t.string "categories", limit: 45
    t.string "tags", default: "", null: false
    t.string "warnings", default: ""
    t.string "fandoms", default: ""
    t.string "characters", default: ""
    t.string "relationships", default: ""
    t.string "language_code", default: "en"
    t.string "url"
    t.boolean "imported", default: false, null: false
    t.boolean "do_not_import", default: false, null: false
    t.string "ao3_url"
    t.string "import_notes", limit: 1024, default: ""
    t.integer "coauthor_id", default: 0
    t.string "language_code", limit: 5
    t.index ["author_id"], name: "authorId"
    t.index ["id"], name: "id_UNIQUE", unique: true
  end

  create_table "story_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "summary"
    t.text "notes"
    t.integer "author_id", default: 0
    t.string "rating", default: "", null: false
    t.datetime "date"
    t.datetime "updated"
    t.string "categories", limit: 45
    t.string "tags", default: "", null: false
    t.string "warnings", default: ""
    t.string "fandoms", default: ""
    t.string "characters", default: ""
    t.string "relationships", default: ""
    t.string "url"
    t.boolean "imported", default: false, null: false
    t.boolean "do_not_import", default: false, null: false
    t.string "ao3_url"
    t.boolean "broken_link", default: false, null: false
    t.string "import_notes", limit: 1024, default: ""
    t.index ["author_id"], name: "authorId"
    t.index ["id"], name: "id_UNIQUE", unique: true
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
