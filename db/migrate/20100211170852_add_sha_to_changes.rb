class AddShaToChanges < ActiveRecord::Migration
  def self.up
    add_column :changes, :sha, :string
  end

  def self.down
    remove_column :changes, :sha
  end
end
