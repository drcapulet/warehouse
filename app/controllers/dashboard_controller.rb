class DashboardController < ApplicationController
  def index
    # @commits = Commit.dashboard.paginate :page => params[:page]
    @events = TimelineEvent.descending.paginate :page => params[:page]
    @repos = Repository.recent_commits.all
    @title = "Dashboard"
  end

end
