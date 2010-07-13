class User < ActiveRecord::Base
  acts_as_authentic
  is_gravtastic :email
  has_permalink :login, :update => true
  
  def to_param
    permalink
  end
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end
  
  def recent_activity(limit = 15)
    TimelineEvent.all(:conditions => {:actor_id => self.id, :actor_type => 'User'}, :order => 'created_at DESC', :limit => limit)
  end
  
  def find_repositories_committed_to
    Commit.all(:conditions => { :email => email }, :order => 'id ASC').collect { |c| c.repository }.uniq
  end
end
