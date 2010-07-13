class UserSessionsController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create]
  before_filter :require_no_user, :only => [:new, :create]
  # before_filter :login_required, :only => :destroy
  layout 'login'
  
  def new
    @user_session = UserSession.new
    @title = "Login"
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    @title = "Login"
    if @user_session.save
      flash.now[:notice] = "Login successful!"
      redirect_back_or_default dashboard_url
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash.now[:notice] = "Logout successful!"
    redirect_back_or_default login_url
  end
end