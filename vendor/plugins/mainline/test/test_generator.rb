# encoding: utf-8

require File.dirname(__FILE__) + "/test_helper"

class TestGenerator < Test::Unit::TestCase
  include DiffFixtureHelper
  
  def setup
    @generator = Diff::Display::Unified::Generator.new
  end
  
  def test_generator_run_raises_if_doesnt_get_a_enumerable_object
    assert_raises(ArgumentError) do
      Diff::Display::Unified::Generator.run(nil)
    end
  end
  
  def test_generator_run_processes_each_line_in_the_diff
    Diff::Display::Unified::Generator.expects(:new).returns(@generator)
    @generator.expects(:process).with("foo")
    @generator.expects(:process).with("bar")
    Diff::Display::Unified::Generator.run("foo\nbar")
  end
  
  def test_generator_run_returns_the_data
    Diff::Display::Unified::Generator.expects(:new).returns(@generator)
    generated = Diff::Display::Unified::Generator.run("foo\nbar")
    assert_instance_of Diff::Display::Data, generated
  end
  
  def test_the_returned_that_object_is_in_parity_with_the_diff
    %w[multiple_rems_then_add only_rem simple multiple_adds_after_rem only_add pseudo_recursive simple_oneliner].each do |diff|
      data = Diff::Display::Unified::Generator.run(load_diff(diff))
      assert_equal load_diff(diff).chomp, data.to_diff, "failed on #{diff}"
    end
  end
  
  def test_big
    diff_data = load_diff("big")
    data = Diff::Display::Unified::Generator.run(diff_data)
    assert_equal diff_data.chomp, data.to_diff
  end
  
  def test_multiple_rems_and_an_add_is_in_parity
    diff_data = load_diff("multiple_rems_then_add")
    data = Diff::Display::Unified::Generator.run(diff_data)
    assert_equal diff_data.chomp, data.to_diff
  end
  
  def test_doesnt_parse_linenumbers_that_isnt_part_if_the_diff
    range = 1..14
    expected_lines = range.to_a.map{|l| [nil, l] }
    assert_equal expected_lines, line_numbers_for(:pseudo_recursive).compact
  end
  
  def test_parses_no_newline_at_end_of_file
    diff_data = load_diff("pseudo_recursive")
    data = Diff::Display::Unified::Generator.run(diff_data)
    assert_equal diff_data.chomp, data.to_diff
    assert_instance_of Diff::Display::NonewlineBlock, data.last
    assert_equal 1, data.last.size
    assert_instance_of Diff::Display::NonewlineLine, data.last[0]
    assert_equal '\\ No newline at end of file', data.last[0]
  end
  
  def test_a_changed_string_becomes_a_modblock
    diff_data = load_diff("simple_oneliner")
    data = Diff::Display::Unified::Generator.run(diff_data)
    
    assert_equal diff_data.chomp, data.to_diff
    assert_equal 6, data.size
    modblock = data[4]
    assert_instance_of Diff::Display::ModBlock, modblock
    assert_equal 2, modblock.size, modblock.inspect
    
    rem = modblock[0]
    add = modblock[1]
    assert_instance_of Diff::Display::RemLine, rem
    assert_instance_of Diff::Display::AddLine, add    
    assert add.inline_changes?
    assert rem.inline_changes?
  end

  # line numbering
  def test_numbers_correctly_for_multiple_adds_after_rem
    expected = [
      [193, 193],
      [194, nil],
      [nil, 194],
      [nil, 195],
      [nil, 196],
      [nil, 197],
      [nil, 198],
      [195, 199]
    ]
    assert_equal expected, line_numbers_for(:multiple_adds_after_rem)
  end

  def test_numbers_correctly_for_simple
    expected = [
      [1, 1],
      [2, 2],
      [3, nil],
      [4, nil],
      [nil, 3],
      [nil, 4],
      [nil, 5],
    ]
    assert_equal expected, line_numbers_for(:simple)
  end
  
  def test_rewrite_line_does_not_set_inline_changes
    diff_data = load_diff("simple_rewrite")
    data = Diff::Display::Unified::Generator.run(diff_data)
    
    assert_equal diff_data.chomp, data.to_diff
    modblock = data[5]
    assert_instance_of Diff::Display::ModBlock, modblock
    
    assert_instance_of Diff::Display::RemLine, rem = modblock[0]
    assert_instance_of Diff::Display::AddLine, add = modblock[1]
    
    assert !rem.inline_changes?, "rem has inline changes"
    assert !add.inline_changes?, "add has inline_changes"
  end
  
  def test_should_not_explode_on_invalid_byte_sequences
    diff_data = "+s\x8B\xB5\x13\n"
    assert_nothing_raised do
      Diff::Display::Unified::Generator.run(diff_data)
    end
  end

  protected
  def line_numbers_for(diff)
    diff_data = load_diff(diff)
    data = Diff::Display::Unified::Generator.run(diff_data)
    linenos = []
    data.each do |blk| 
      blk.each do |line|
        next if line.class == Diff::Display::HeaderLine
        next if line.class == Diff::Display::NonewlineLine
        linenos << [line.old_number, line.new_number]
      end
    end
    linenos
  end
end
