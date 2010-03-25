class BrowserController < ApplicationController
  include Warehouse::RepositoryResources
  before_filter :find_node, :except => [:multi, :tag]
  before_filter :render_sync_required_unless_current_commit, :only => [:index, :blame]
    
  def index
    render :action => @node.node_type
  end
  
  alias blame index
  
  def text
    render :text => @node.data, :content_type => Mime::TEXT
  end

  def raw
    if content = @node.data
      send_data content, :disposition => 'inline', :content_type => @node.mime_type
    else
      head :not_found
    end
  end
  
  def hil
    render :action => 'hil', :layout => false
  end
  
  def multi
  end
  
  def history
    @changes = Change.paginate(:page => params[:page], :per_page => 15, :conditions => { :path =>  (params[:paths] * '/'), :commit_id => current_repository.commits.all(:conditions => { :branch => current_commit.branch }) })
  end
  
  def tag
    r = current_repository.tags.detect { |t| t.name == params[:tag].to_s }
    @revision = r.commit.tree.id
    @node = current_repository.node('', @revision)
    params[:paths] = []
    render :action => 'dir'
  end
  
  protected
    def render_sync_required_unless_current_commit
      render :action => 'sync_required' unless current_commit
    end
end
