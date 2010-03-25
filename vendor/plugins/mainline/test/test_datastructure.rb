# encoding: utf-8

require File.dirname(__FILE__) + "/test_helper"

class TestDatastructure < Test::Unit::TestCase
  include DiffFixtureHelper  
  
  # Data
  def test_behaves_like_an_array
    data = Diff::Display::Data.new
    data << "foo"
    data.push "bar"
    assert_equal ["foo", "bar"], data
  end
  
  # Line
  def test_initializes_with_an_old_line_number
    line = Diff::Display::Line.new("foo", 12)
    assert_equal 12, line.old_number
  end

  def test_initializes_with_numbers
    line = Diff::Display::Line.new("foo", 12, 13)
    assert_equal 12, line.old_number
    assert_equal 13, line.new_number
  end
  
  def test_has_a_class_method_for_creating_an_addline
    line = Diff::Display::Line.add("foo", 7)
    assert_instance_of Diff::Display::AddLine, line
  end
  
  def test_has_a_class_method_for_creating_a_remline
    line = Diff::Display::Line.rem("foo", 7)
    assert_instance_of Diff::Display::RemLine, line
  end
  
  def test_has_a_class_method_for_creating_a_unmodline
    line = Diff::Display::Line.unmod("foo", 7, 8)
    assert_instance_of Diff::Display::UnModLine, line
  end
  
  def test_has_a_class_method_for_creating_a_header_line
    line = Diff::Display::Line.header("foo")
    assert_instance_of Diff::Display::HeaderLine, line
  end
  
  def test_has_an_identifier
    assert_equal :add, Diff::Display::Line.add("foo", 7).identifier
    assert_equal :rem, Diff::Display::Line.rem("foo", 7).identifier
    assert_equal :unmod, Diff::Display::Line.unmod("foo", 7, 8).identifier
    assert_equal :header, Diff::Display::Line.header("foo").identifier
    assert_equal :nonewline, Diff::Display::Line.nonewline("foo").identifier
  end
  
  def test_expands_inline_changes
    line = Diff::Display::AddLine.new('the \\0quick \\1brown fox', 42, true)
    expanded = line.expand_inline_changes_with("START", "END")
    assert_equal "the STARTquick ENDbrown fox", expanded.to_s
  end
  
  def test_segments
    line = Diff::Display::AddLine.new('the \\0quick \\1brown fox', 42, true)
    assert_equal ["the ", "quick ", "brown fox"], line.segments
  end
  
  # Block
  def test_block_behaves_like_an_array
    block = Diff::Display::Block.new
    block.push 1,2,3
    assert_equal 3, block.size
    assert_equal [1,2,3], block
  end
  
  def test_has_class_method_for_creating_an_addblock
    block = Diff::Display::Block.add
    assert_instance_of Diff::Display::AddBlock, block
  end
  
  def test_has_class_method_for_creating_an_remblock
    block = Diff::Display::Block.rem
    assert_instance_of Diff::Display::RemBlock, block
  end
  
  def test_has_class_method_for_creating_an_modblock
    block = Diff::Display::Block.mod
    assert_instance_of Diff::Display::ModBlock, block
  end
  
  def test_has_class_method_for_creating_an_unmodblock
    block = Diff::Display::Block.unmod
    assert_instance_of Diff::Display::UnModBlock, block
  end
  
  def test_has_class_method_for_creating_an_headerblock
    block = Diff::Display::Block.header
    assert_instance_of Diff::Display::HeaderBlock, block
  end
  
end
