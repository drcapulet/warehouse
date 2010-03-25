class AddCommitsCountToRepositories < ActiveRecord::Migration
  def self.up
    add_column :repositories, :commits_count, :integer
  end

  def self.down
    remove_column :repositories, :commits_count
  end
end
