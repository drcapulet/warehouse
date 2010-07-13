class Commit < ActiveRecord::Base
  belongs_to :repository, :counter_cache => true
  belongs_to :parent, :class_name => "Commit"
  has_one :next,  :class_name => "Commit", :foreign_key => 'parent_id'
  has_many :changes, :dependent => :destroy
  is_gravtastic :email, :size => 32, :default => '/images/app/icons/member.png'
  named_scope :dashboard, :order => 'committed_date DESC'
  
  def actor
    actor_id ? user : name
  end
  
  def user
    User.find_by_email(email)
  end
  
  def to_param
    sha
  end
  
  def self.find_by_tree_and_or_branch(b, t = nil)
    if b && t
      first(:conditions => { :branch => b, :tree => t }, :order => 'committed_date DESC')
    else
      first(:conditions => { :branch => b }, :order => 'committed_date DESC')
    end
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
