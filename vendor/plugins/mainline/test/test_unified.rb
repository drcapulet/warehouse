require File.dirname(__FILE__) + "/test_helper"

class TestUnified < Test::Unit::TestCase
  include DiffFixtureHelper
  
  def test_generates_its_data_structure_via_the_generator
    generator_data = mock("Generator mock")
    Diff::Display::Unified::Generator.expects(:run).returns(generator_data)
    diff = Diff::Display::Unified.new(load_diff("simple"))
    assert_equal generator_data, diff.data
  end
  
  def test_renders_a_diff_via_a_callback_and_renders_it_to_a_stringlike_object
    diff = Diff::Display::Unified.new(load_diff("simple"))
    callback = mock()
    callback.expects(:render).returns("foo")
    output = ""
    diff.render(callback, output)
    assert_equal "foo", output
  end
  
end
