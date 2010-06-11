class TimelineEvent < ActiveRecord::Base
  belongs_to :actor,              :polymorphic => true
  belongs_to :subject,            :polymorphic => true
  belongs_to :secondary_subject,  :polymorphic => true
  serialize :extra
  
  named_scope :descending, { :order => 'created_at DESC' }
  
  def commits
    Commit.all(:conditions => ["id in (?)", extra["commits"].collect(&:to_i)], :order => 'committed_date ASC') if event_type == "push"
  end
end
