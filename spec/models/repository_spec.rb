require 'spec_helper'

describe Repository do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :path => "value for path",
      :slug => "value for slug",
      :synced_revision => "value for synced_revision",
      :synced_revision_at => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    Repository.create!(@valid_attributes)
  end
end
