REPO_ROOT_REGEX = /^(\/?(admin|changesets|browser|install|login|logout|reset|forget))(\/|$)/

ActionController::Routing::Routes.draw do |map|
  
  map.with_options :path_prefix => '/:repo' do |repo|
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
