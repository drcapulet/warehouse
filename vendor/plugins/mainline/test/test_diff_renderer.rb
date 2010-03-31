# encoding: utf-8

require File.dirname(__FILE__) + "/test_helper"

class TestDiffRenderer < Test::Unit::TestCase
  include DiffFixtureHelper
  
  def test_it_renders_a_diff_back_to_its_original_state
    data = Diff::Display::Unified::Generator.run(load_diff("simple"))
    base_renderer = Diff::Renderer::Diff.new
    assert_equal load_diff("simple"), base_renderer.render(data)
  end
end

