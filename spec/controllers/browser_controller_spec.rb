require 'spec_helper'

describe BrowserController do

  #Delete these examples and add some real ones
  it "should use BrowserController" do
    controller.should be_an_instance_of(BrowserController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'text'" do
    it "should be successful" do
      get 'text'
      response.should be_success
    end
  end

  describe "GET 'raw'" do
    it "should be successful" do
      get 'raw'
      response.should be_success
    end
  end
end
