require 'spec_helper'

describe "/commits/index" do
  before(:each) do
    render 'commits/index'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/commits/index])
  end
end
