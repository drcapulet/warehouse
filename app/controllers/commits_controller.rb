class CommitsController < ApplicationController
  before_filter :find_query, :except => :show
  def index
  end

  def show
    @commit = current_repository.commits.find_by_sha(params[:id])
  end
  
  def search
    render :action => 'index'
  end
  
  def feed
    @commits = !params[:tree].empty? ? current_repository.commits.all(:conditions => { :branch => params[:tree] }, :order => 'committed_date DESC', :limit => 30) : current_repository.commits(:order => 'committed_date DESC', :limit => 30)
    respond_to do |wants|
      wants.atom
      wants.rss
    end
  end
  
  protected
    def find_query
      params[:tree] ||= 'master'
      if params[:q] && params[:tree]
        conds = ["message LIKE ? AND branch = ?", '%' + params[:q] + '%', params[:tree]]
      elsif params[:tree]
        conds = { :branch => params[:tree] }
      else
        conds = nil
      end
      @commits = current_repository.commits.paginate(:page => params[:page], :per_page => 15, :conditions => conds, :order => 'committed_date DESC') 
    end

end
