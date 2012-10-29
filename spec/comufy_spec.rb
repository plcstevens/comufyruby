require "spec_helper"

describe Comufy do

  it "should return a Comufy::Connector object" do
    Comufy.connector.class.should == Comufy::Connector
  end

  it "should return same object when calling Comufy.connector twice" do
    object = Comufy.connector
    object.should == Comufy.connector
  end

  it "should create a new different object when calling Comufy.new_connector" do
    object = Comufy.connector
    object.should_not == Comufy.new_connector
  end
end
