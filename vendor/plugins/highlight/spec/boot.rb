plugin_root = File.join(File.dirname(__FILE__), '..')

require 'rubygems'
gem 'rails'
require 'activerecord'
require 'active_support'
require 'action_controller'
require 'action_view'

$:.unshift "#{plugin_root}/lib"

RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + '/../')
Rails::Initializer.run(:set_load_path)
Rails::Initializer.run(:set_autoload_paths)

require File.join(File.dirname(__FILE__), '/../init.rb')

FileUtils.mkdir_p(File.join(File.dirname(__FILE__), 'log'))
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), 'log', 'spec.log'))
