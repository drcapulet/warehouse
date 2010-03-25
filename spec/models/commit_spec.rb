require 'spec_helper'

describe Commit do
  before(:each) do
    @valid_attributes = {
      :sha => "value for sha",
      :message => "value for message",
      :name => "value for name",
      :email => "value for email",
      :actor_id => 1,
      :committed_date => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    Commit.create!(@valid_attributes)
  end
end
