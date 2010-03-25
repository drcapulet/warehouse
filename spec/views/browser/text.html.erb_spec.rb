require 'spec_helper'

describe "/browser/text" do
  before(:each) do
    render 'browser/text'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/browser/text])
  end
end
