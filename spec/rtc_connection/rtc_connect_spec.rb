require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe "Given connection information" do
  before(:all) do
    #
  end
  
  it "should successfully log in" do
    connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    expect(connection.rtc).not_to be_nil    
  end
  
  it "should fail when given bad credentials" do
    config = YetiTestUtils::modify_config_data(
      RTCSpecHelper::RTC_STATIC_CONFIG,           #1 CONFIG  - The config file to be augmented
      "RTCConnection",                            #2 SECTION - XML element of CONFIG to be augmented
      "User",                                     #3 NEWTAG  - New tag name in reference to REFTAG
      "Fred",                                     #4 VALUE   - New value to put into NEWTAG
      "replace",                                  #5 ACTION  - [before, after, replace, delete]
      "User") 
      
    expect{RTC_connect(config) }.to raise_error(/Could not authenticate/)
  end
end