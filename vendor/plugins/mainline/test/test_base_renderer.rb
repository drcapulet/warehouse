# encoding: utf-8

require File.dirname(__FILE__) + "/test_helper"

class TestBaseRenderer < Test::Unit::TestCase
  include DiffFixtureHelper
  
  def setup
    @data = Diff::Display::Unified::Generator.run(load_diff("big"))
    @base_renderer = Diff::Renderer::Base.new
  end
  
  def test_it_classifies_a_classname
    assert_equal "remblock", @base_renderer.send(:classify, Diff::Display::RemBlock.new)
  end
  
  def test_it_calls_the_before_headerblock
    @base_renderer.expects(:before_headerblock).at_least_once
    @base_renderer.render(@data)
  end
  
  # def test_it_calls_the_before_sepblock
  #   @base_renderer.expects(:before_sepblock).at_least_once
  #   @base_renderer.render(@data)
  # end
  
  # def test_it_calls_the_before_modblock
  #   @base_renderer.expects(:before_modblock).at_least_once
  #   @base_renderer.render(@data)
  # end
  
  def test_calls_the_before_unmodblock
    @base_renderer.expects(:before_unmodblock).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_should_calls_the_before_addblock
    @base_renderer.expects(:before_addblock).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_calls_the_before_remblock
    @base_renderer.expects(:before_remblock).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_calls_headerline
    @base_renderer.expects(:headerline).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_calls_unmodline
    @base_renderer.expects(:unmodline).at_least_once
    @base_renderer.render(@data)
  end  
  
  def test_calls_addline
    @base_renderer.expects(:addline).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_calls_remline
    @base_renderer.expects(:remline).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_calls_the_after_headerblock
    @base_renderer.expects(:after_headerblock).at_least_once
    @base_renderer.render(@data)
  end
  
  # def test_calls_the_after_sepblock
  #   @base_renderer.expects(:after_sepblock).at_least_once
  #   @base_renderer.render(@data)
  # end
  
  # def test_calls_the_after_modblock
  #   @base_renderer.expects(:after_modblock).at_least_once
  #   @base_renderer.render(@data)
  # end
  
  def test_calls_the_after_unmodblock
    @base_renderer.expects(:after_unmodblock).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_calls_the_after_addblock
    @base_renderer.expects(:after_addblock).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_calls_the_after_remblock
    @base_renderer.expects(:after_remblock).at_least_once
    @base_renderer.render(@data)
  end
  
  def test_renders_a_basic_datastructure
    output = @base_renderer.render(@data)
    assert_not_equal nil, output
  end
end
