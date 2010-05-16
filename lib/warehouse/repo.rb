module Warehouse
  class Repo
    def initialize(repository)
      @repository = repository
      @path       = repository.path
    end
    
    attr_accessor :path
    
    def valid?
      begin
        !!grit_object
      rescue
        false
      end
    end
    
    def node_at(path, tree = 'master')
      Node.new(self, path, tree)
    end
    
    def grit_object
      @grit_object ||= Grit::Repo.new(@path)
    end
    
    def latest_revision(branch = 'master')
      grit_object.log(branch, '', :max_count => 1).first
    end
    
    def full_tree(branch = 'master')
      tree = grit_object.tree(branch)
      tree_to_array(tree)
    end
    
    def commit(id)
      grit_object.commit(id)
    end
    
    def tree(tree)
      grit_object.tree(tree)
    end
    
    def head(head)
      grit_object.get_head(head)
    end
    
    protected
      def tree_to_array(tree)
        contents = []
        tree.contents.sort!{ |x,y| x.name.downcase <=> y.name.downcase }.each { |b| contents << (b.is_a?(Grit::Blob) ? b.name : { b.name => tree_to_array(b) }) }
        contents
      end
    
    
  end
end