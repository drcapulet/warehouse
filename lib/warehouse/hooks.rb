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
require 'net/http'
require 'uri'

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
    BITLY_API_LOGIN = YAML.load_file("config/bitly.yml")['login']
    BITLY_API_KEY   = YAML.load_file("config/bitly.yml")['key']
    
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
      
      def fake_payload
        { 
          :ref => "master",
          :before => "9bf67315bfbba7843f7b786f9e2f7a24053c9066",
          :after => "857cd26dd6c8ff5e5b65264f6f07d6b055e3b19c",
          :commits => [
            {
              :id => "3629d2ad854848547bfd583a5b2a01e29ba7da01",
              :message=>"Fixed a problem with the application controller",
              :moved => [],
              :removed => [],
              :added => [],
              :modified => ["app/controllers/application_controller.rb"],
              :author => {
                :avatar => "http://www.gravatar.com/avatar/?d=identicon&s=80&r=g",
                :email => "joe@schmo.con",
                :name => "Joe Schmo" }, 
              :timestamp => "2010-06-09T20:07:36Z",
              :url => "http://warehouse.local/warehouse/commit/3629d2ad854848547bfd583a5b2a01e29ba7da01"
            }
          ],
          :repository => {
            :name => "Warehouse",
            :url => "http://localhost:5060/warehouse"
          }
        }
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
          def config
            self.class.config
          end
          def shorten_url(url)
            self.class.shorten_url(url)
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
        
        def controller_actions
          @controller_actions ||= {}
        end
        
        def view_links
          @view_links ||= {}
        end
        
        def display_info
          @display_info ||= []
        end
        
        def help_text
          @help ||= ""
        end
        
        def config
          @config
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
        
        # Going to be parsed with markdown. Probably. Or something similar. This isnt done.
        def help(h)
          warn("Help for hooks isn't done yet. It currently just spits out whatever you pass it.")
          @help = h
        end
        
        # DISPLAYS VARIABLE TEXT - MUST ALSO BE DEFINED AS AN OPTION - and the value will be auto populated
        # if there is a variable saved for that key
        #   display_variable :some_option
        #   option :some_option, "", :as => :hidden
        def display_variable(property)
          display_info << property
        end
        
        # ADDING this to the top of your hook will automatically load RAILS_ROOT/config/hooks/plugin_name.yml
        def has_config
          @config = YAML.load_file("config/hooks/#{plugin_name}.yml")
        end
        
        # Let's start imagining examples:
        #   define_controller_action :action_name, <<-EOF
        #     &block
        #   EOF
        #   end
        # would generate
        #   def hook_name_action_name
        #     &block
        #   end
        # and a named root
        #  map.with_options :path_prefix => '/:repo' do |repo|
        #    repo.with_options :controller => "repositories" do |a|
        #      ....
        #      a.hook_name_action_name "admin/hooks/hook_name/action_name", :action => "hook_name_action_name"
        #    end
        #  end
        # The block you pass will be stored as a proc and then called whenver the action is requested
        def define_controller_action(name, *args, &block)
          controller_actions[name.to_s] = args.first
        end
        
        # Add in links to the view - must match an action defined by define_controller_action
        # They look the same as the other buttons and are added after the test hook button
        # Example:
        #   define_view_link "Some Text", :action_name
        def define_view_link(text, action_symbol)
          view_links[action_symbol] = text
        end
        
        # Call shorten_url (it is remapped to the class method by the service class wich your hook inherits from)
        # to shorten a url using the bit.ly service - login & api_key set in config/bitly.yml
        def shorten_url(url)
          Net::HTTP.get(URI.parse("http://api.bit.ly/v3/shorten?login=#{BITLY_API_LOGIN}&apiKey=#{BITLY_API_KEY}&longUrl=#{CGI.escape(url)}&format=txt")).gsub!(/\n/,'')
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
            klass.send(name, *args, &block)
          else
            if %w(run init).include?(name.to_s)
              method_name = name
              klass.send :define_method, method_name, &block
            # else
              # method_name = "retrieving_#{name}"
              # var_name    = method_name.to_s.gsub(/\W/, '')
              # # klass.expiring_attr_reader name, method_name
              # klass.send :class_eval, ("
              #   def #{method_name}
              #     def self.#{method_name}; @#{var_name}; end
              #     @#{var_name} ||= eval(%(#{name}))
              #   end
              # ")
            end
          end
        end
    end
  end
end