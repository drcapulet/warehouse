require File.dirname(__FILE__) + '/../spec_helper'

describe Simplabs::Highlight::ViewMethods do

  include Simplabs::Highlight::ViewMethods

  before do
    @ruby_code = 'class Test; end'
  end

  describe '#highlight' do

    describe 'when invoked with a language and a string' do

      it 'should highlight the code' do
        Simplabs::Highlight.should_receive(:highlight).once.with(:ruby, @ruby_code)

        highlight(:ruby, @ruby_code)
      end

    end

    describe 'when invoked with a language and a block' do

      it 'should highlight the code' do
        Simplabs::Highlight.should_receive(:highlight).once.with(:ruby, @ruby_code)

        highlight(:ruby) do
          @ruby_code
        end
      end

    end

    describe 'when invoked with both a string and a block' do

      it 'should raise an ArgumentError' do
        lambda { highlight(:ruby, @ruby_code) { @ruby_code } }.should raise_error(ArgumentError)
      end

    end

    describe 'when invoked with neither a string nor a block' do

      it 'should raise an ArgumentError' do
        lambda { highlight(:ruby) }.should raise_error(ArgumentError)
      end

    end

  end

end
