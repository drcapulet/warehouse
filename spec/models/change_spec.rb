require 'spec_helper'

describe Change do
  before(:each) do
    @valid_attributes = {
      :repository_id => 1,
      :mode => "value for mode",
      :path => "value for path",
      :from_path => "value for from_path",
      :from_revision => "value for from_revision"
    }
  end

  it "should create a new instance given valid attributes" do
    Change.create!(@valid_attributes)
  end
end
