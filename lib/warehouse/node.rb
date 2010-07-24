require 'grit'

module Warehouse
  class Node
    
    @@file_extensions = Set.new(%w(txt rb php python rhtml erb phps phtml shtml html c js json atom xml htm bas css yml))
    @@image_mime_regex  = /(png|jpe?g|gif|ico)/i
    attr_accessor :path, :revision
    
    def initialize(repository, path, tree = 'master', grit_object = nil)
      @repository = repository
      @path       = path
      @tree       = tree
      @grit_object= grit_object
    end
    
    def name
      @name ||= File.basename(@path) + (self.dir? ? '/' : '')
    end
    
    def paths
      @paths ||= @path.split("/")
    end
    
    def dir?
      grit_object.is_a?(Grit::Tree)
    end

    def file?
      grit_object.is_a?(Grit::Blob)
    end
  
    def exists?
      !grit_object.nil?
    end
    
    def node_type
      dir? ? 'dir' : 'file'
    end
    
    def mime_type
      @mime_type ||= file? ? File.extname(name)[1..-1] : nil
    end
    
    def text?
      return false unless file?
      @@file_extensions.include?(mime_type) || name =~ /^\.?[^\.]+$/
    end
    
    def image?
      mime_type && mime_type =~ @@image_mime_regex
    end
    
    def data
      self.file? ? grit_object.data : turn_reponse_to_nodes(grit_object.contents)
    end
    
    def latest_revision(date)
      grit_repo.log('', @path, :max_count => 1, :until => date.utc.xmlschema).first
    end
    
    def blame(revision)
      @blame ||= Grit::Blame.new(@repository.grit_object, path, revision)
    end
    
    def exists?
      !!grit_object
    end
    
    protected
      def grit_object
        if @path.empty?
          @grit_object ||= grit_repo.tree(@tree)
        else
          @grit_object ||= grit_repo.tree(@tree)/(@path)
        end
      end
      
      def grit_repo
        @grit_repo ||= @repository.grit_object
      end
    
      def turn_reponse_to_nodes(resp)
          ret = []
          resp.each do |r|
            p = path.empty? ? r.name : (path + '/' + r.name)
            ret << self.class.new(@repository, p, @tree, r)
          end
          ret
      end
  end
end