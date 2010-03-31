# require "test/unit"
# $:.unshift File.dirname(__FILE__) + "/../lib/"
# require "diff-display"
require File.join(File.dirname(__FILE__), "/../lib/diff-display")

if RUBY_VERSION > '1.9'
  gem 'test-unit', ">=0"
  class Test::Unit::TestCase
    PASSTHROUGH_EXCEPTIONS = [NoMemoryError, SignalException, Interrupt, SystemExit]
  end
end
require 'test/unit'
require "rubygems"
gem("mocha", ">=0")
require "mocha"
begin
  require "redgreen"
rescue LoadError
end

module DiffFixtureHelper
  def load_diff(name)
    File.read(File.dirname(__FILE__) + "/fixtures/#{name}.diff")
  end
end