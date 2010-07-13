module UsersHelper
  def recent_commits_for(user, limit = 15)
    Commit.all(:conditions => {:email => user.email}, :order => 'committed_date DESC', :limit => limit)
  end
  
  def actor_link_for_event(event)
    event.actor ? link_to(event.actor.name, user_path(event.actor)) : event.commits.last.name
  end
end
