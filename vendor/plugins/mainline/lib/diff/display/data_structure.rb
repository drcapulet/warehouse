module Diff
  module Display
    class Data < Array
      def initialize
        super
      end
      
      def to_diff
        diff = ""
        each do |block|
          block.each do |line|
            line_str = line.expand_inline_changes_with(nil, nil)
            case line
            when HeaderLine
              diff << "#{line_str}\n"
            when UnModLine
              diff << " #{line_str}\n"
            when SepLine
              diff << "\n"
            when AddLine
              diff << "+#{line_str}\n"
            when RemLine
              diff << "-#{line_str}\n"
            when NonewlineLine
              diff << line_str
            end
          end
        end
        diff.chomp
      end
      
      def debug
        demodularize = Proc.new {|obj| obj.class.name[/\w+$/]}
        each do |diff_block|
          print "-" * 40, ' ', demodularize.call(diff_block)
          puts
          puts diff_block.map {|line| 
            # "%5d" % line.old_number + 
            "%8s" % "[#{line.old_number || '.'} #{line.new_number || '.'}]" +
            " [#{demodularize.call(line)}#{'(i)' if line.inline_changes?}]" +
            line
          }.join("\n")
          puts "-" * 40, ' ' 
        end
        nil
      end
    end
    
    # Every line from the passed in diff gets transformed into an instance of
    # one of line Line class's subclasses. One subclass exists for each line
    # type in a diff. As such there is an AddLine class for added lines, a RemLine
    # class for removed lines, an UnModLine class for lines which remain unchanged and
    # a SepLine class which represents all the lines that aren't part of the diff.
    class Line < String
      class << self
        def add(line, line_number, inline = false)
          AddLine.new(line, line_number, inline)
        end
      
        def rem(line, line_number, inline = false)
          RemLine.new(line, line_number, inline)
        end
      
        def unmod(line, old_number, new_number)
          UnModLine.new(line, old_number, new_number)
        end
        
        def nonewline(line)
          NonewlineLine.new(line)
        end
        
        def header(line)
          HeaderLine.new(line)
        end
      end
      
      def initialize(line, old_number = nil, new_number = nil)
        super(line)
        @old_number, @new_number = old_number, new_number
        @inline = false
      end
      attr_reader :old_number, :new_number
      
      def identifier
        self.class.name[/\w+$/].gsub(/Line$/, "").downcase.to_sym
      end
      
      def inline_changes?
        # Is set in the AddLine+RemLine subclasses
        @inline
      end
      
      # returns the prefix, middle and postfix parts of a line with inline changes
      def segments
        return self.dup unless inline_changes?
        prefix, changed = self.dup.split('\\0')
        changed, postfix = changed.split('\\1')
        [prefix, changed, postfix]
      end
      
      # Expand any inline changes with +prefix+ and +postfix+
      def expand_inline_changes_with(prefix, postfix)
        return self.dup unless inline_changes?
        str = self.dup
        str.sub!('\\0', prefix.to_s)
        str.sub!('\\1', postfix.to_s)
        str
      end
      
      def inspect
        %Q{#<#{self.class.name} [#{old_number.inspect}-#{new_number.inspect}] "#{self}">}
      end
    end
    
    # class AddLine < Line
    #   def initialize(line, line_number)
    #     super(line, nil, line_number)
    #   end
    # end
    # 
    # class RemLine < Line
    #   def initialize(line, line_number)
    #     super(line, line_number, nil)
    #   end
    # end
    class AddLine < Line
      def initialize(line, line_number, inline = false)
        super(line, nil, line_number)
        @inline = inline
      end
    end
    
    class RemLine < Line
      def initialize(line, line_number, inline = false)
        super(line, line_number, nil)
        @inline = inline
      end
    end
    
    class NonewlineLine < Line
      def initialize(line = '\\ No newline at end of file')
        super(line)
      end      
    end
    
    class UnModLine < Line
      def initialize(line, old_number, new_number)
        super(line, old_number, new_number)
      end
    end
    
    class SepLine < Line
      def initialize(line = '...')
        super(line)
      end
    end
    
    class HeaderLine < Line
      def initialize(line)
        super(line)
      end
    end
    
    # This class is an array which contains Line objects. Just like Line
    # classes, several Block classes inherit from Block. If all the lines
    # in the block are added lines then it is an AddBlock. If all lines
    # in the block are removed lines then it is a RemBlock. If the lines
    # in the block are all unmodified then it is an UnMod block. If the
    # lines in the block are a mixture of added and removed lines then
    # it is a ModBlock. There are no blocks that contain a mixture of
    # modified and unmodified lines.
    class Block < Array
      class << self
        def add;    AddBlock.new    end 
        def rem;    RemBlock.new    end
        def mod;    ModBlock.new    end
        def unmod;  UnModBlock.new  end
        def header; HeaderBlock.new end
        def nonewline; NonewlineBlock.new end
      end
    end

    #:stopdoc:#
    class AddBlock    < Block;  end  
    class RemBlock    < Block;  end
    class ModBlock    < Block;  end
    class UnModBlock  < Block;  end
    class SepBlock    < Block;  end
    class HeaderBlock < Block;  end
    class NonewlineBlock < Block; end
    #:startdoc:#
  end
end