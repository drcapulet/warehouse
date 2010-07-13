# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :current_repository, :current_commit, :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  
  before_filter :login_required
  
  protected
  
    def current_repository
      @repo = Repository.find_by_slug(repository_name)
    end
    
    def repository_name
      @repository_name ||= params.delete(:repo)
    end
    
    def current_commit
      # @latest_commit ||= @revision ? current_repository.commits.find_by_tree(@revision) : current_repository.commits.first
      @lastest_commit ||= @text_revision.match(/[a-zA-Z0-9]{40}/) ? current_repository.commits.find_by_tree(@revision) : current_repository.commits.find_by_tree_and_or_branch(@text_revision)
    end

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def login_required
      unless current_user
        store_location
        flash.now[:error] = "You must be logged in to access that page"
        redirect_to login_url
        return false
      end
    end

    def require_no_user
      if current_user
        # flash[:notice] = "You must be logged out to access this page"
        # redirect_to account_url
        redirect_to dashboard_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def load_user_using_perishable_token  
      @user = User.find_using_perishable_token(params[:token])
      unless @user
        flash.now[:error] = "We're sorry, but we could not locate your account. If you are having issues try copying and pasting the URL " +  
        "from your email into your browser or restarting the reset password process."
        redirect_to login_url
      end
    end
end
