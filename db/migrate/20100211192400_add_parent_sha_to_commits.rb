class AddParentShaToCommits < ActiveRecord::Migration
  def self.up
    add_column :commits, :parent_sha, :string
  end

  def self.down
    remove_column :commits, :parent_sha
  end
end
