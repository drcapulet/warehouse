$:.reject! { |e| e.include? 'TextMate' }

ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'spec'
require 'test/unit'
require 'active_support'
require 'initializer'

require File.join(File.dirname(__FILE__), 'boot')
