$:.unshift File.dirname(__FILE__)

module Diff
  module Display
  end
end

require "diff/display/version"
require "diff/display/data_structure"
require "diff/display/unified"
require "diff/display/unified/generator"

require "diff/renderer/base"
require "diff/renderer/diff"