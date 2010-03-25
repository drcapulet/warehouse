class CreateCommits < ActiveRecord::Migration
  def self.up
    create_table :commits do |t|
      t.integer :repository_id
      t.string :sha
      t.string :message
      t.string :name
      t.string :email
      t.integer :actor_id
      t.datetime :committed_date

      t.timestamps
    end
  end

  def self.down
    drop_table :commits
  end
end
