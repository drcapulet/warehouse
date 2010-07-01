class RepositoriesController < ApplicationController
  def index
    @title = 'Repositories'
    @repos = Repository.all
  end
  
  def new
    @repo = Repository.new
  end
  
  def create
    @repo = Repository.new(params[:repository])
    if @repo.save
      flash[:notice] = "Repository created successfully!"
      redirect_to repositories_path
    else
      flash[:error] = "Repository couldn't be created!"
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if current_repository.update_attributes(params[:repository])
      flash[:notice] = "The repository was updates successfully!"
      redirect_to admin_path
    else
      render :action => "edit"
    end
  end
  
  def delete
  end
  
  def hooks
    @hooks = Warehouse::Hooks.list
  end
  
  def hooks_update
    hook_name = params[:hook][:name]
    hook      = eval("current_repository.hooks.#{hook_name}_new")
    options   = params[:hook][:options]
    active    = params[:hook][:active]
    if hook.id
      hook.update_attributes({ :options => options, :active => active })
    else
      hook.options = options
      hook.active  = active
      hook.save
    end
    if request.xhr?
      render :text => "<div class=\"flash-notice mini\">Your #{hook_name.gsub!(/_/, ' ')} hook was updated successfully! <span class=\"close\">x</span></div>"
    else
      flash[:notice] = "Your hooks have been updated successfully!"
      redirect_to admin_hooks_path
    end
  end
  
  def hooks_update_post
    urls = params['array']['urls'].delete_if {|x| x == "" }
    if urls.length > 0
      if current_repository.hooks.post_receive
        current_repository.hooks.post_receive.update_attribute(:options, { 'urls' => urls })
      else
        h = current_repository.hooks.post_receive_new
        h.options['urls'] = urls
        h.repository = current_repository
        h.save
      end
    else
      current_repository.hooks.post_receive.delete if current_repository.hooks.post_receive
    end
    if request.xhr?
      render :text => "<div class=\"flash-notice mini\">Your post receive hook was updated successfully! <span class=\"close\">x</span></div>"
    else
      flash[:notice] = "Your hooks have been updated successfully!"
      redirect_to admin_hooks_path
    end
  end
  
  def hooks_update_email
    emails = params['hook']['emails'].delete_if {|x| x == "" }
    if emails.length > 0
      if current_repository.hooks.email
        current_repository.hooks.email.update_attribute(:options, { 'emails' => emails })
      else
        h = current_repository.hooks.email_new
        h.options['emails'] = emails
        h.repository = current_repository
        h.save
      end
    else
      current_repository.hooks.email.delete if current_repository.hooks.email
    end
    if request.xhr?
      render :text => "<div class=\"flash-notice mini\">Your email hook was updated successfully!</div> <span class=\"close\">x</span></div>"
    else
      flash[:notice] = "Your hooks have been updated successfully!"
      redirect_to admin_hooks_path
    end
  end
  
  def sync
  end
  
  def search
    @repos = Repository.all(:conditions => ["name LIKE ?", '%' + params[:q] + '%'])
  end
  
  Warehouse::Hooks.list.each do |k, hook|
    class_eval("def #{k}_hook_test
      h = eval(\"current_repository.hooks.#{k}\")
      h.runnit(Warehouse::Hooks.fake_payload)
      render :text => 'success'
    end")
  end
  
  
end
