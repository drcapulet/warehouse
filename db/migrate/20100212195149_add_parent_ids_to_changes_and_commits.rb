class AddParentIdsToChangesAndCommits < ActiveRecord::Migration
  def self.up
    add_column :changes, :parent_id, :integer
    add_column :commits, :parent_id, :integer
  end

  def self.down
    remove_column :changes, :parent_id, :integer
    remove_column :commits, :parent_id, :integer
  end
end
