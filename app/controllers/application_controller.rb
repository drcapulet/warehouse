# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :current_repository, :current_commit

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  # expiring_attr_reader :current_repository, :retrieve_current_repository
  # expiring_attr_reader :current_commit, :retrieve_latest_revision
  
  protected
  
    def current_repository
      @repo = Repository.find_by_slug(repository_name)
    end
    
    def repository_name
      @repository_name ||= params.delete(:repo)
    end
    
    def current_commit
      @latest_commit ||= @revision ? current_repository.commits.find_by_tree(@revision) : current_repository.commits.first
    end
end
