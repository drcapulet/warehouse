feed.entry(commit, :url => commit_path_for_current(commit)) do |entry|
  entry.title("[#{commit.sha}] #{truncate(h(commit.message), 50)} by #{commit.name}")
  entry.summary(simple_format(h(commit.message)), :type => :html)
  entry.content("<ul>#{render :partial => commit.changes, :locals => { :i => 0 }}</ul>", :type => 'html')
  entry.updated(commit.committed_date.xmlschema)
  entry.author do |author|
    author.name(commit.name)
  end
end