class Repository < ActiveRecord::Base
  attr_accessible :name, :slug, :synced_revision, :synced_revision_at, :path
  has_many :commits, :order => 'commits.committed_date DESC', :dependent => :destroy
  has_one  :latest_commit, :class_name => 'Commit', :foreign_key => 'repository_id', :order => 'committed_date desc'
  has_many :hooks, :order => 'name desc'
  
  validates_presence_of :name, :path
  validates_uniqueness_of :slug
  named_scope :recent_commits, :order => 'synced_revision_at DESC'
  validate :valid_grit_repo
  before_save :set_slug
  
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
    if latest_commit_for_branch(branch) && latest_unsynced_revision_for_branch(branch)
      latest_unsynced_revision_for_branch(branch).sha != (latest_commit_for_branch(branch).sha)
    else
      true
    end
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
  
  def process_hooks(payload)
    self.hooks.active.each { |h| h.runnit(payload) }
  end
  
  def valid_grit_repo
    errors.add(:path, "That path isn't a valid Git repo!")  unless silo.valid?
  end
  
  def set_slug
    s = name.dup
    s.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
    s.gsub!(/[^\w_ \-]+/i,   '') # Remove unwanted chars.
    s.gsub!(/[ \-]+/i,      '-') # No more than one of the separator in a row.
    s.gsub!(/^\-|\-$/i,      '') # Remove leading/trailing separator.
    s.downcase!
    self.slug = s
  end
  
end
