# encoding: utf-8

require File.dirname(__FILE__) + "/test_helper"

class TestApi < Test::Unit::TestCase
  include DiffFixtureHelper

  def test_it_has_a_simple_API
    diff = Diff::Display::Unified.new(load_diff("simple"))
    diff.render(Diff::Renderer::Base.new)
  end
end