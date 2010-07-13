module DashboardHelper
  def timeline_event_avatar_for(event)
    event.actor ? avatar_for(event.actor) : avatar_for(event.commits.last)
  end
end
