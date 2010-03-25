# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100212195149) do

  create_table "changes", :force => true do |t|
    t.string   "mode"
    t.string   "path"
    t.string   "from_path"
    t.string   "from_revision"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sha"
    t.integer  "commit_id"
    t.integer  "parent_id"
  end

  create_table "commits", :force => true do |t|
    t.integer  "repository_id"
    t.string   "sha"
    t.string   "message"
    t.string   "name"
    t.string   "email"
    t.integer  "actor_id"
    t.datetime "committed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "branch"
    t.integer  "changes_count"
    t.string   "tree"
    t.string   "parent_sha"
    t.integer  "parent_id"
  end

  create_table "repositories", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.string   "slug"
    t.string   "synced_revision"
    t.datetime "synced_revision_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commits_count"
  end

end
