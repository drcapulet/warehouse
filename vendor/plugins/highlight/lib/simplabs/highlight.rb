module Simplabs

  # = Highlight
  #
  # Highlight is a simple syntax highlighting plugin for Ruby on Rails. It's basically a wrapper around the popular http://pygments.org
  # highlighter that's written in Python and supports a huge number of languages.
  module Highlight

    mattr_accessor :initialized

    SUPPORTED_LANGUAGES = {
      :as            => ['as', 'as3', 'actionscript'],
      :applescript   => ['applescript'],
      :bash          => ['bash', 'sh'],
      :c             => ['c', 'h'],
      :clojure       => ['clojure'],
      :cpp           => ['c++', 'cpp', 'hpp'],
      :csharp        => ['c#', 'csharp', 'cs'],
      :css           => ['css'],
      :diff          => ['diff'],
      :dylan         => ['dylan'],
      :erlang        => ['erlang'],
      :html          => ['html', 'htm'],
      :java          => ['java'],
      :js            => ['javascript', 'js', 'jscript'],
      :jsp           => ['jsp'],
      :make          => ['make', 'basemake', 'makefile'],
      :'objective-c' => ['objective-c'],
      :ocaml         => ['ocaml'],
      :perl          => ['perl', 'pl'],
      :php           => ['php'],
      :python        => ['python', 'py'],
      :rhtml         => ['erb', 'rhtml'],
      :ruby          => ['ruby', 'rb'],
      :scala         => ['scala'],
      :scheme        => ['scheme'],
      :smallralk     => ['smalltalk'],
      :smarty        => ['smarty'],
      :sql           => ['sql', 'mysql'],
      :xml           => ['xml', 'xsd'],
      :xslt          => ['xslt'],
      :yaml          => ['yaml', 'yml']
    }

    # Highlights the passed +code+ with the appropriate rules according to the specified +language+.
    #
    # <b>Supported Languages</b>
    #
    # The following languages are supported. All of the paranthesized identifiers may be used as parameters for highlight to denote the
    # language the source code to highlight is written in (use either Symbols or Strings).
    #
    # * Actionscript (as, as3, actionscript)
    # * Applescript (applescript)
    # * bash (bash, sh)
    # * C (c, h)
    # * Clojure (clojure)
    # * C++ (c++, cpp, hpp)
    # * C# (c#, csharp, cs)
    # * CSS (css)
    # * diff (diff)
    # * Dylan (dylan)
    # * Erlang (erlang, erl, er)
    # * HTML (html, htm)
    # * Java (java)
    # * JavaScript (javascript, js, jscript)
    # * JSP (jsp)
    # * Make (make, basemake, makefile)
    # * Objective-C (objective-c)
    # * OCaml (ocaml)
    # * Perl (perl, pl)
    # * PHP (php)
    # * Python (python, (py)
    # * RHTML (erb, rhtml)
    # * Ruby (ruby, rb)
    # * Scala (scala)
    # * Scheme (scheme)
    # * Smalltalk (smalltalk)
    # * Smarty (smarty)
    # * SQL (sql)
    # * XML (xml, xsd)
    # * XSLT (xslt)
    # * YAML (yaml, yml)
    def self.highlight(language, code, linenos = true)
      return CGI.escapeHTML(code) unless Simplabs::Highlight.initialized
      Simplabs::Highlight::PygmentsWrapper.highlight(code, language, linenos)
    end

    # Highlight view methods
    module ViewMethods

      # Highlights the passed +code+ with the appropriate rules according to the specified +language+. The code can
      # be specified either as a string or as result f a block.
      #
      # <b>Examples:</b>
      #
      #  highlight(:ruby, 'class Test; end')
      #
      #  highlight(:ruby) do
    	#	   <<-EOF
    	#		   class Test
      #			 end
    	#	   EOF
    	#  end 
    	#
    	# Also see Simplabs::Highlight.highlight
      def highlight(language, code = nil, linenos = true, &block)
        raise ArgumentError.new('Either pass a srting containing the code or a block, not both!') if !code.nil? && block_given?
        raise ArgumentError.new('Pass a srting containing the code or a block!') if code.nil? && !block_given?
        code ||= yield
        Simplabs::Highlight.highlight(language, code, linenos)
      end

    end

  end

end
