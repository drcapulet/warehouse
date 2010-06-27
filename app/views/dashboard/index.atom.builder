atom_feed(:root_url => root_url, :schema_date => Time.utc(2010, 1, 1)) do |feed|
  feed.title("Warehouse Activity Feed")
  feed.updated((@events.first ? @events.first.created_at : Time.now.utc))
  
  @events.each do |event|
    if event.event_type == "push"
      feed.entry(event, :url => commits_url(:repo => event.subject, :tree => event.extra['ref'])) do |entry|
        entry.title("#{event.commits.last.name} pushed to #{event.subject.name}/#{event.extra['ref']}")
        con = "<ul>"
        event.commits.each do |c|
          con += "<li>#{avatar_for(c)} #{link_to truncate(c.sha, :length => 7, :omission => ''), commit_path(:id => c.sha, :repo => c.repository)} #{c.message}</li>"
        end
        con += "</ul>"
        entry.content(con, :type => 'html')
        entry.updated(event.created_at)
        entry.author do |au|
          au.name(event.commits.last.name)
        end
      end
    end
    
  end
end