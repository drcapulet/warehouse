REPO_ROOT_REGEX = /^(\/?(admin|changesets|browser|install|login|logout|reset|forget))(\/|$)/

ActionController::Routing::Routes.draw do |map|
  map.resources :repositories, :only => [:index, :new, :create], :collection => [:search]
  map.dashboard       "/dashboard", :controller => 'dashboard', :action => 'index'
  map.dashboard_feed  "/dashboard.atom", :controller => 'dashboard', :action => 'index', :format => 'atom'
  # AUTH
  map.resource    :account, :controller => "users"
  map.resources   :users, :only => [:show]
  map.login       "/login", :controller => "user_sessions", :action => 'new', :conditions => { :method => :get }
  map.login       "/login", :controller => "user_sessions", :action => 'create', :conditions => { :method => :post }
  map.logout      "/logout", :controller => "user_sessions", :action => 'destroy'
  map.signup      "/signup", :controller => 'users', :action => 'new', :conditions => { :method => :get }
  map.signup      "/signup", :controller => 'users', :action => 'create', :conditions => { :method => :post }
  map.forgot_pw   "/forgot", :controller => 'users', :action => 'forgot', :conditions => { :method => :get }
  map.forgot_pw   "/forgot", :controller => 'users', :action => 'forgot_post', :conditions => { :method => :post }
  map.reset_pw    "/reset/:token", :controller => 'users', :action => 'reset', :conditions => { :method => :get }
  map.reset_pw    "/reset/:token", :controller => 'users', :action => 'reset_post', :conditions => { :method => [:post, :put] }
  
  map.with_options :path_prefix => '/:repo' do |repo|
    # repo.resources :admin, :except => [:index, :new, :create, :show], :controller_name => "Repositories"
    repo.with_options :controller => "repositories" do |a|
      a.admin           "admin",      :action => 'edit',    :conditions => { :method => [:get] }
      a.admin           "admin",      :action => 'update',  :conditions => { :method => [:post, :put] }
      a.admin_hooks     "admin/hooks",:action => 'hooks',   :conditions => { :method => [:get] }
      a.admin_hooks     "admin/hooks",:action => 'hooks_update', :conditions => { :method => [:post, :put] }
      a.admin_hooks_post "admin/hooks/post_receive", :action => 'hooks_update_post', :conditions => { :method => [:post, :put] }
      a.admin_hooks_email "admin/hooks/email", :action => 'hooks_update_email', :conditions => { :method => [:post, :put] }
      a.admin_delete    "admin/nuke", :action => 'delete',  :conditions => { :method => [:get, :post, :delete] }
      a.admin_git_hook  "admin/install_git_hook", :action => 'install_git_hook', :conditions => { :method => [:get] }
      Warehouse::Hooks.list.each do |hook_name, hook|
        hook.controller_actions.each do |name, proc|
          eval("a.admin_#{hook_name}_#{name} \"admin/hooks/#{hook_name}/#{name}\", :action => \"#{hook_name}_#{name}\"")
        end
      end
    end
    repo.connect 'admin/:action', :controller => "repositories"
    repo.with_options :controller => "commits" do |c|
      c.all_commits     "commits",            :action => "index"
      c.search_commits  "commits/search",     :action => "search"
      c.commits         "commits/:tree",      :action => "index"
      c.commits_feed    "commits/:tree.atom", :action => "feed", :format => 'atom'
      c.commit          "commit/:id",         :action => "show"
    end
    repo.with_options :controller => "browser" do |b|
      b.history     "tree/:tree/history/*paths", :action => "history"
      b.tree        "tree/:rev/*paths", :action => "index"
      # b.browser     "browser/*paths"
      b.tag         "tag/*tag",       :action => "tag"
      b.blame       "blame/:rev/*paths",   :action => "blame"
      b.text        "text/*paths",    :action => "text"
      b.raw         "raw/*paths",     :action => "raw"
      b.hil         "hil/*paths",     :action => "hil"
      b.multi       "multi",          :action => "multi"
      b.multi_list  "multi-list",     :action => "multi_list"
      b.search      "search",         :action => "search"
      # b.repo        "tree/*paths",    :action => "index"
      b.repo        "*paths",         :action => "index"
    end
  end
  
  map.root :controller => "dashboard"
  
  # map.repo '/:repo', :controller => 'browser', :action => 'index'
  
  #   repo.with_options :controller => "browser" do |b|
  #     b.rev_browser "browser/:rev/*paths", :rev => /r\w+/
  #     b.browser     "browser/*paths"
  #     b.blame       "blame/*paths", :action => "blame"
  #     b.text        "text/*paths",  :action => "text"
  #     b.raw         "raw/*paths",   :action => "raw"
  #   end
  # end
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
