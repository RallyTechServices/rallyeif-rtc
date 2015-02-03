require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

# these tests require log in
describe "Given configuration in the RTCConnection section and logging in," do
  before(:all) do
    #
  end
  
  it "should successfully validate a basic config file " do
    connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    # TestConfig::RTC_PROJECTAREA_ID
    expect(connection.validate).to be true
    expect(connection.query_link).to match(/^http.*#{Regexp.escape(TestConfig::RTC_PROJECTAREA_ID)}/)
    expect(connection.factory_link).to match(/^http.*contexts\/#{Regexp.escape(TestConfig::RTC_PROJECTAREA_ID)}/)
  end
  
  it "should reject invalid project area" do
    fred_project_config = YetiTestUtils::modify_config_data(
                            RTCSpecHelper::RTC_STATIC_CONFIG,           #1 CONFIG  - The config file to be augmented
                            "RTCConnection",                                   #2 SECTION - XML element of CONFIG to be augmented
                            "ProjectArea",                                           #3 NEWTAG  - New tag name in reference to REFTAG
                            "Fred",                                                   #4 VALUE   - New value to put into NEWTAG
                            "replace",                                                #5 ACTION  - [before, after, replace, delete]
                            "ProjectArea")                                           #6 REFTAG  - Existing tag in SECTION
    expect { RTC_connect(fred_project_config) }.to raise_error(/Cannot find <ProjectArea>/)
  end
  
  it "should reject invalid artifact types" do
    fred_artifact_config = YetiTestUtils::modify_config_data(
                            RTCSpecHelper::RTC_STATIC_CONFIG,           #1 CONFIG  - The config file to be augmented
                            "RTCConnection",                                   #2 SECTION - XML element of CONFIG to be augmented
                            "ArtifactType",                                           #3 NEWTAG  - New tag name in reference to REFTAG
                            "Fred",                                                   #4 VALUE   - New value to put into NEWTAG
                            "replace",                                                #5 ACTION  - [before, after, replace, delete]
                            "ArtifactType")                                           #6 REFTAG  - Existing tag in SECTION
    expect{ RTC_connect(fred_artifact_config) }.to raise_error(/Cannot find <ArtifactType>/)
  end
  
  it "should generate a reasonable fetch result" do
    connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    connection.validate
    
    #expect( connection.get_fetch() ).to eq("dc:title,rtc_cm:com.ibm.team.apt.attribute.complexity{*},rtc_cm:state{*},rtc_cm:teamArea{*},#{TestConfig::RTC_EXTERNAL_ID_FIELD}")
    expect( connection.get_fetch() ).to eq("*{*}")
  end
end