class CreateTimelineEvents < ActiveRecord::Migration
  def self.up
    create_table :timeline_events do |t|
      t.string :event_type
      t.references :subject,  :polymorphic => true
      t.references :actor,    :polymorphic => true
      t.references :secondary_subject, :polymorphic => true
      t.text :extra
      t.timestamps
    end
  end

  def self.down
    drop_table :timeline_events
  end
end
