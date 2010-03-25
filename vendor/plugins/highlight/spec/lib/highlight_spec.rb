require File.dirname(__FILE__) + '/../spec_helper'

describe Simplabs::Highlight do

  before do
    @ruby_code = <<-EOC
class Test
  def method test
  end
end
EOC
  end

  describe '#highlight' do

    describe 'when Highlight is not initialized' do

      before do
        Simplabs::Highlight.initialized = false
      end

      it 'should only CGI excape the passed code' do
        Simplabs::Highlight.initialized = false

        Simplabs::Highlight.highlight(:ruby, @ruby_code).should == @ruby_code
      end

    end

    describe 'when Highlight is initialized' do

      before do
        Simplabs::Highlight.initialized = true
      end

      it 'should call Simplabs::PygmentsWrapper.highlight with the language and code' do
        Simplabs::Highlight::PygmentsWrapper.should_receive(:highlight).once.with(@ruby_code, :ruby)

        Simplabs::Highlight.highlight(:ruby, @ruby_code)
      end

      it 'should correctly highlight source code passed as parameter' do
        Simplabs::Highlight.highlight(:ruby, @ruby_code).should == "<span class=\"k\">class</span> <span class=\"nc\">Test</span>\n  <span class=\"k\">def</span> <span class=\"nf\">method</span> <span class=\"nb\">test</span>\n  <span class=\"k\">end</span>\n<span class=\"k\">end</span>"
      end

    end

  end

end
