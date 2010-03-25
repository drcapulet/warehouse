module Diff
  module Renderer
    class Diff < Base      
      def headerline(line)
        line
      end
      
      def unmodline(line)
        " #{line}"
      end
      
      def remline(line)
        "-#{line}"
      end
      
      def addline(line)
        "+#{line}"
      end
      
      def nonewlineline(line)
        line.to_s
      end
      
      def new_line
        "\n"
      end
    end
  end
end