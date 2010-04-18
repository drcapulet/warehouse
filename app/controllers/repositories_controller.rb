class RepositoriesController < ApplicationController
  def index
    @repos = Repository.all
  end
  
  def new
    @repo = Repository.new
  end
  
  def create
    @repo = Repository.new(params[:repository])
    if @repo.save
      flash[:notice] = "Repository created successfully!"
      redirect_to repositories_path
    else
      flash[:error] = "Repository couldn't be created!"
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if current_repository.update_attributes(params[:repository])
      flash[:notice] = "The repository was updates successfully!"
      redirect_to admin_path
    else
      render :action => "edit"
    end
  end
  
  def delete
  end
  
  def hooks
  end
  
  def hooks_update
  end
  
  def sync
  end
end
