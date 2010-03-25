class Commit < ActiveRecord::Base
  belongs_to :repository, :counter_cache => true
  belongs_to :parent, :class_name => "Commit"
  has_one :next,  :class_name => "Commit", :foreign_key => 'parent_id'
  has_many :changes
  is_gravtastic :email, :size => 32, :default => '/images/app/icons/member.png'
  
  def actor
    actor_id ? user : name
  end  
  
  def to_param
    sha
  end
  
  def grit_object
    @grit_object ||= repository.silo.commit(sha)
  end
  
  def diffs
    @grit_diffs ||= grit_object.diffs
  end
  
  def grit_tree
    @grit_tree ||= grit_object.tree
  end
end
