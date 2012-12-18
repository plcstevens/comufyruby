require "spec_helper"

describe Comufy do

  before :each do
    @comufy = Comufy.new user: 'user', password: 'password'
  end

  it "should have configured the user" do
    @comufy::config.user.should == 'user'
  end

  it "should have configured the password" do
    @comufy::config.password.should == 'password'
  end

  it "should have configured the default url" do
    @comufy::config.base_api_url.should == 'http://www.sociableapi.com/xcoreweb/client'
  end

  it "should have not configured the access token" do
    @comufy::config.access_token.should == nil
  end

  it "should have not configured the expiry time" do
    @comufy::config.expiry_time.should == nil
  end
end
