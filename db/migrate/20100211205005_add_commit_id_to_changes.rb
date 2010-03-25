class AddCommitIdToChanges < ActiveRecord::Migration
  def self.up
    add_column :changes, :commit_id, :integer
  end

  def self.down
    remove_column :changes, :commit_id
  end
end
