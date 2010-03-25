module Warehouse
  module RepositoryResources
  
  protected
    def find_node
      if params[:rev]
        @revision = params[:rev].match(/[a-zA-Z0-9]{40}/) ? params[:rev] : current_repository.head(params[:rev]).commit.tree.id
      else  
        @revision = current_repository.head('master').commit.tree.id
      end
      @node = current_repository.node(params[:paths] * '/', @revision)
    end
    
    # def find_current_revision
    #    @commit = current_repository.commits.find_by_sha(@revision)
    #  end
   
  end
end