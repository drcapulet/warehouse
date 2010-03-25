class Change < ActiveRecord::Base
  belongs_to :commit, :counter_cache => true
  belongs_to :parent, :class_name => "Change" #, :foreign_key => "from_revision", :primary_key => 'sha'
  has_one :next,  :class_name => "Change", :foreign_key => 'parent_id'
  
  def to_param
    sha
  end
end
