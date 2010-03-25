require 'spec_helper'

describe "/browser/raw" do
  before(:each) do
    render 'browser/raw'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/browser/raw])
  end
end
