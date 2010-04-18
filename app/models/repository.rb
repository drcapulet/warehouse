class Repository < ActiveRecord::Base
  attr_accessible :name, :slug, :synced_revision, :synced_revision_at
  has_many :commits, :order => 'commits.committed_date DESC', :dependent => :destroy
  has_one  :latest_commit, :class_name => 'Commit', :foreign_key => 'repository_id', :order => 'committed_date desc'
  
  validates_presence_of :name, :path
  
  def to_param
    slug
  end
  
  def silo
    @silo ||= Warehouse::Repo.new(self)
  end
  
  def node(path, tree = 'master')
    silo.node_at(path, tree)
  end
  
  def sync_revisions
    Warehouse::Syncer.process(self)
  end
  
  def latest_commit_for_branch(branch = 'master')
    commits.first(:conditions => {:branch => branch}, :order => 'committed_date DESC')
  end
  
  def latest_unsynced_revision_for_branch(branch = 'master')
    silo.latest_revision(branch)
  end
  
  def has_unsynced_revisions?(branch = 'master')
    latest_unsynced_revision_for_branch(branch).sha != latest_commit_for_branch(branch).sha
  end
  
  def full_tree(branch = 'master')
    silo.full_tree(branch)
  end
  
  def all_committers(branch = 'master', limit = 10)
    # opts.merge({:select => 'distinct name, email'})
    commits.all(:order => 'committed_date DESC', :group => 'email', :limit => limit, :conditions => {:branch => branch})
  end
  
  def tree(tree = 'master')
    silo.tree(tree)
  end
  
  def head(head = 'master')
    silo.head(head)
  end
  
  def heads
    silo.grit_object.heads
  end
  
  def tags
    silo.grit_object.tags
  end
  
end
