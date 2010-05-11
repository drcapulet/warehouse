REPO_ROOT_REGEX = /^(\/?(admin|changesets|browser|install|login|logout|reset|forget))(\/|$)/

ActionController::Routing::Routes.draw do |map|
  map.resources :repositories, :only => [:index, :new, :create], :collection => [:search]
  
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
    end
    repo.with_options :controller => "commits" do |c|
      c.all_commits     "commits",            :action => "index"
      c.search_commits  "commits/search",     :action => "search"
      c.commits         "commits/:tree",      :action => "index"
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
  
  # map.root :controller => "dashboard"
  
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
  
  map.root :controller => "application"
end
