require "spec_helper"

describe Comufy do

  it "should return a Comufy::Connector object" do
    Comufy.connector.class.should == Comufy::Connector
  end
end
