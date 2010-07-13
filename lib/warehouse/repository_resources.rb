module Warehouse
  module RepositoryResources
  
  protected
    def find_node
      if params[:rev]
        @revision = params[:rev].match(/[a-zA-Z0-9]{40}/) ? params[:rev] : current_repository.head(params[:rev]).commit.tree.id
        @text_revision = params[:rev].match(/[a-zA-Z0-9]{40}/) ? @revision : params[:rev]
      else  
        @revision = current_repository.head('master').commit.tree.id
        @text_revision = 'master'
      end
      if params[:paths]
        @node = current_repository.node(params[:paths] * '/', @revision)
      else
         @node = current_repository.node('/', @text_revision)
      end
    end
    
    # def find_current_revision
    #    @commit = current_repository.commits.find_by_sha(@revision)
    #  end
   
  end
end