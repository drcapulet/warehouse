class CreateChanges < ActiveRecord::Migration
  def self.up
    create_table :changes do |t|
      t.int :repository_id
      t.string :mode
      t.string :path
      t.string :from_path
      t.string :from_revision

      t.timestamps
    end
    add_column :commits, :changes_count, :integer
  end

  def self.down
    drop_table :changes
    drop_column :commits, :changes_count
  end
end
