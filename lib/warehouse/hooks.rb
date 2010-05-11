$LOAD_PATH.unshift *Dir["#{RAILS_ROOT}/vendor/hooks/**/lib"]
# stdlib
# require 'net/http'
# require 'net/https'
# require 'net/smtp'
# require 'socket'
# require 'timeout'
# require 'xmlrpc/client'
# require 'openssl'
# require 'cgi'
# 
# require 'mime/types'
# require 'xmlsimple'
# require 'activesupport'
# require 'rack'
# # require 'sinatra'
# require 'tinder'
# require 'json'
# @ require 'tinder'
# # require 'basecamp'
# require 'tmail'
# require 'xmpp4r'
# require 'xmpp4r-simple'
# require 'rubyforge'

module Warehouse
  module Hooks
    class << self
      attr_accessor :discovered
      attr_accessor :index
      attr_accessor :hook_path

      def [](plugin_name)
        index[plugin_name.to_s]
      end
    end
    
    self.discovered = []
    self.index      = {}
    self.hook_path = RAILS_ENV == 'test' ? 'test/hooks' : 'lib/warehouse/hooks'
    
    class << self
      def list
        discover if index == {}
        index
      end

      def discover
        path ||= Warehouse::Hooks.hook_path
        Dir[File.join(path, "*")].each do |dir|
          name = File.basename(dir).gsub!(/.rb/, "")
          # next unless File.directory?(dir)
          hook_name = Service.class_name_of(name)
          require dir unless const_defined?(hook_name)
          next if index.key?(name)
          hook = class_eval("Warehouse::Hooks::#{hook_name}") #const_get(hook_name)
          discovered             << hook
          # index[Service.underscore(Service.demodulize(hook))] = hook
          index[hook.plugin_name] = hook
        end
        discovered
      end
      
      def define(service, &block)
        hook_name = Service.class_name_of(service)
        # hook_class = Class.new(Service)
        class_eval <<-EOF
        class #{hook_name} < Service
          def initialize(d, p)
            @data = d
            @payload = p
          end
          def data
            @data.options
          end
          def payload
            @payload
          end
        end
        EOF
        hook_class = class_eval("#{hook_name}")
        begin
          Proxy.process!(hook_class, &block)
          hook_class.new([],[]).init
        rescue LoadError => boom
          puts ""
          puts "#### WAREHOUSE HOOK ERROR -- GEM REQUIREMENT ####"
          puts boom
          puts "You probably need to install the gem#{boom.message.split('--').last}"
          puts "", boom.backtrace, ""
          exit 0
        end
      end
    end
    
    class Service
      # def initialize(hook, payload)
      #   @data = hook.options
      #   @payload = payload
      # end
      def run!
        init if respond_to?(:init) # plugin-specific startup stuff
        run
      end
      class << self
        def plugin_name
          @plugin_name ||= underscore(demodulize(name))
        end
        
        def html_name
          @html_name ||= demodulize(name)
        end
        
        def class_name_of(n)
          camelize n
        end
        
        def default_options
          @default_options ||= {}
        end
        
        def options_info
          @options_info ||= {}
        end
        
        def options_html
          @options_html ||= {}
        end
        
        def option(property, *args)
          format  = args.first.is_a?(Regexp) ? args.shift : nil
          desc    = args.shift
          html_opts = args.shift || {}
          default = nil
          class_eval <<-END, __FILE__, __LINE__
            def #{property}
              options[:#{property}].to_s.empty? ? #{default.inspect} : options[:#{property}]
            end

            def #{property}=(value)
              options[:#{property}] = value#{" if value.to_s =~ #{format.inspect}" if format}
            end
          END
          # option_order << "#{property} #{desc}".strip
          # default_options[property.to_sym] = default
          options_info[property.to_sym] = desc
          options_html[property.to_sym] = html_opts
          # option_formats[property.to_sym]  = format if format
        end
        
        # Going tp be parsed with markdown. Probably. Or something similar. This isnt done.
        def help(h)
          warn("Help for hooks isn't done yet. It is just a future TODO")
          # class_eval <<-END, __FILE__, __LINE__
          #     def help
          #       @help
          #     end
          #   END
        end
        
        private
          def camelize(lower_case_and_underscored_word)
            lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
          end

          def demodulize(modulized)
            modulized.to_s.gsub(/^.+::/, '')
          end

          def underscore(camel_cased_word)
            camel_cased_word.to_s.gsub(/::/, '/').
              gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
              gsub(/([a-z\d])([A-Z])/,'\1_\2').
              tr("-", "_").
              downcase
          end
      end
    end
    class Proxy
      attr_reader :klass
    
      def self.process!(klass, &block)
        new(klass).instance_eval &block
      end
    
      def initialize(klass)
        @klass = klass
      end
      
      private
        def method_missing(name, *args, &block)
          if klass.respond_to?(name)
            klass.send(name, *args)
          else
            if %w(run init).include?(name.to_s)
              method_name = name
            else
              method_name = "retrieving_#{name}"
              var_name    = method_name.to_s.gsub(/\W/, '')
              # klass.expiring_attr_reader name, method_name
              klass.send :class_eval, ("
                def #{method_name}
                  def self.#{method_name}; @#{var_name}; end
                  @#{var_name} ||= eval(%(#{name}))
                end
              ")
            end
            klass.send :define_method, method_name, &block
          end
        end
    end
  end
end