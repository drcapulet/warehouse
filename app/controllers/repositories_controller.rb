class RepositoriesController < ApplicationController
  def index
    @title = 'Repositories'
    @repos = Repository.all
  end
  
  def new
    @title = "New Repository"
    @repo = Repository.new
  end
  
  def create
    @repo = Repository.new(params[:repository])
    if @repo.save
      flash[:notice] = "Repository created successfully!"
      redirect_to repositories_path
    else
      flash[:error] = "Repository couldn't be created!"
      @title = "New Repository"
      render :action => 'new'
    end
  end
  
  def edit
    @title = "Admin"
  end
  
  def update
    if current_repository.update_attributes(params[:repository])
      flash[:notice] = "The repository was updated successfully!"
      redirect_to admin_path
    else
      render :action => "edit"
    end
  end
  
  def delete
  end
  
  def hooks
    @title = "Hooks"
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
      render :text => "<div class=\"flash-notice mini\">Your email hook was updated successfully! <span class=\"close\">x</span></div>"
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
  
  def install_git_hook
    @root = RAILS_ROOT
    template = ERB.new File.new("lib/post_receive.erb").read, nil, "%"
    file = template.result(binding)
    # this is where we need to write the file to the correct directory
    if File.exist?(File.join(current_repository.path, '.git'))
      p = File.join(current_repository.path, '.git', 'hooks')
    elsif File.exist?(current_repository.path) && (current_repository.path =~ /\.git$/)
      p = File.join(current_repository.path, 'hooks')
    else
    end
    if p
      path = File.join(p, 'post-receive')
      File.open(path, 'w') { |f| f.write(file); f.chmod(0755) }
    end
    flash[:notice] = "The hook was successfully installed!"
    redirect_to admin_path
  end
  
  Warehouse::Hooks.list.each do |k, hook|
    class_eval("def #{k}_hook_test
      h = eval(\"current_repository.hooks.#{k}\")
      h.runnit(Warehouse::Hooks.fake_payload)
      render :text => 'success'
    end")
  end
  
  
end
