class AddTreeShaToCommit < ActiveRecord::Migration
  def self.up
    add_column :commits, :tree, :string
  end

  def self.down
    remove_column :commits, :tree
  end
end
