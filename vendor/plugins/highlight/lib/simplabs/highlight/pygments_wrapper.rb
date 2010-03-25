require 'cgi'

module Simplabs

  module Highlight

    class PygmentsWrapper #:nodoc:

      class << self

        def highlight(code, language, linenums = true)
          return CGI.escapeHTML(code) if !(language = get_language_sym(language))
          filename = "/tmp/highlight_#{Time.now.to_f}"
          File.open(filename, 'w') { |f|
            f << code
            f << "\n"
          }
          result = `pygmentize -f html #{'-O linenos=true' unless linenums == false}  -l #{language} #{filename}`
          result.chomp
        end

        protected

          def get_language_sym(name)
            Simplabs::Highlight::SUPPORTED_LANGUAGES.each_pair do |key, value|
              return key if value.any? { |lang| lang == name.to_s }
            end
            return false
          end

      end

    end

  end

end
