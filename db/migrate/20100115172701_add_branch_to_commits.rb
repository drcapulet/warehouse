class AddBranchToCommits < ActiveRecord::Migration
  def self.up
    add_column :commits, :branch, :string
  end

  def self.down
    remove_column :commits, :branch
  end
end
