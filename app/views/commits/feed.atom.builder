atom_feed(:root_url => commits_url(:tree => params[:tree]), :schema_date => Time.utc(2010, 1, 1)) do |feed|
  feed.title("Changesets for #{current_repository.name}/#{params[:tree]}")
  feed.updated((@commits.first ? @commits.first.committed_date : Time.now.utc))

  @commits.each do |commit|
    render :partial => commit, :locals => { :feed => feed }
  end
end