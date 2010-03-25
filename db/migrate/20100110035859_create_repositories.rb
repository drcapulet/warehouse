class CreateRepositories < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.string :name
      t.string :path
      t.string :slug
      t.string :synced_revision
      t.datetime :synced_revision_at

      t.timestamps
    end
  end

  def self.down
    drop_table :repositories
  end
end
