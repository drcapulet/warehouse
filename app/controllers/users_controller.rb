class UsersController < ApplicationController
  skip_before_filter :login_required, :except => [:show, :edit, :update]
  before_filter :require_no_user, :only => [:new, :create, :forgot, :forgot_post, :reset, :reset_post]
  before_filter :load_user_using_perishable_token, :only => [:reset, :reset_post]
  before_filter :set_layout
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def show
    if request.path == account_path
      @user = @current_user
    else
      @user = User.find_by_permalink(params[:id])
    end
    @title = "#{@user.login}'s profile"
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def edit
    @title = "Editing your profile"
    @user = @current_user
  end
  
  def update
    @title = "Editing your profile"
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      puts flash.inspect
      redirect_to edit_account_url
    else
      render :action => :edit
    end
  end
  
  def forgot
    @title = 'Forgotten Password'
  end
  
  def forgot_post
    @user = User.find_by_email(params[:email])
    @title = 'Forgotten Password'
    if @user
      @user.deliver_password_reset_instructions!
      flash.now[:notice] = "Instructions to reset your password have been emailed to you."
      @hide_form = true
    else
      flash.now[:error] = "No user was found with that email address"
    end
    render :action => :forgot
  end
  
  def reset
    @title = 'Reset your Password'
  end
  
  def reset_post
    @title = 'Reset your Password'
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash.now[:notice] = "Password successfully updated"
      redirect_to account_url
    else
      render :action => :reset
    end
  end
  
  protected
    def set_layout
      if [:new, :create, :forgot, :forgot_post, :reset, :reset_post].include?(action_name.to_sym)
        self.class.layout 'login'
      end
    end
  private
    def single_access_allowed?
      action_name == "show" && params[:format] && (params[:format] == "atom")
    end
end