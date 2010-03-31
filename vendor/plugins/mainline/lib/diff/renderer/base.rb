module Diff
  module Renderer
    class Base
      def render(data)
        result = []
        data.each do |block|
          result << send("before_" + classify(block), block)
          result << block.map { |line| send(classify(line), line) }
          result << send("after_" + classify(block), block)
        end
        result.compact.join(new_line)
      end
      
      def before_headerblock(block)
      end
      
      def before_unmodblock(block)
      end
      
      def before_modblock(block)
      end
      
      def before_remblock(block)
      end
      
      def before_addblock(block)
      end
      
      def before_sepblock(block)
      end
      
      def before_nonewlineblock(block)
      end
      
      def headerline(line)
        line
      end
      
      def unmodline(line)
        line
      end
      
      def remline(line)
        line
      end
      
      def addline(line)
        line
      end
      
      def sepline(line)
        
      end
      
      def nonewlineline(line)
        line
      end
      
      def after_headerblock(block)
      end
      
      def after_unmodblock(block)
      end
      
      def after_modblock(block)
      end
      
      def after_remblock(block)
      end
      
      def after_addblock(block)
      end
      
      def after_sepblock(block)
      end
      
      def after_nonewlineblock(block)
      end
      
      def new_line
        ""
      end
      
      protected
        def classify(object)
          object.class.name[/\w+$/].downcase 
        end
    end
  end
end