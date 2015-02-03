require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe "Given configuration in the RTCConnection section," do
  before(:all) do
    #
  end
   
  it "should successfully load basic config settings " do
    connection = getRTCConnection(RTCSpecHelper::RTC_STATIC_CONFIG)
    expect( connection.artifact_type ).to  eq(TestConfig::RTC_ARTIFACT_TYPE.downcase.to_sym)
  end
  
  it "should reject missing required fields" do
    expect { getRTCConnection(RTCSpecHelper::RTC_MISSING_ARTIFACT_CONFIG) }.to raise_error(/ArtifactType must not be null/)
    expect { getRTCConnection(RTCSpecHelper::RTC_MISSING_URL_CONFIG) }.to raise_error(/Url must not be null/)
    expect { getRTCConnection(RTCSpecHelper::RTC_MISSING_PROJECT_AREA_CONFIG) }.to raise_error(/ProjectArea must not be null/)
  end
  
  it "should be OK with tags named <ExternalEndUserIDField>, <CrosslinkUrlField> and <IDField>" do
    # Checking <ExternalEndUserIDField>
    connection = getRTCConnection(RTCSpecHelper::RTC_EXTERNAL_FIELDS_CONFIG)
    expect(connection.external_end_user_id_field).to eq(TestConfig::RTC_EXTERNAL_EU_ID_FIELD.to_sym)
    expect(connection.external_item_link_field).to eq(TestConfig::RTC_CROSSLINK_FIELD.to_sym)
    expect(connection.id_field).to eq(TestConfig::RTC_ID_FIELD)
  end
  
  it "should be OK with missing <ExternalEndUserIDField>, <CrosslinkUrlField> and <IDField>" do
    # Checking <ExternalEndUserIDField>
    connection = getRTCConnection(RTCSpecHelper::RTC_STATIC_CONFIG)
    expect(connection.external_end_user_id_field).to be_nil
    expect(connection.external_item_link_field).to be_nil
    expect( connection.id_field ).to eq("dc:identifier")
  end
  
  it "should read copy query" do
    connection = getRTCConnection(RTCSpecHelper::RTC_QUERY_CONFIG)
    expect(connection.copy_query).to eq("dc:identifier=1")
  end
  
  it "should read copy query" do
    connection = getRTCConnection(RTCSpecHelper::RTC_QUERY_CONFIG)
    expect(connection.copy_query).to eq("dc:identifier=1")
  end
  
  it "should remove spaces from copy query" do
    config = YetiTestUtils::modify_config_data(
      RTCSpecHelper::RTC_QUERY_CONFIG,           #1 CONFIG  - The config file to be augmented
      "RTCConnection",                           #2 SECTION - XML element of CONFIG to be augmented
      "CopyQuery",                               #3 NEWTAG  - New tag name in reference to REFTAG
      "dc:identifier =  1",                                    #4 VALUE   - New value to put into NEWTAG
      "replace",                                 #5 ACTION  - [before, after, replace, delete]
      "CopyQuery") 
      connection = getRTCConnection(config)
      expect(connection.copy_query).to eq("dc:identifier=1")
  end
  
  it "should get a basic query for finding new items " do
    connection = getRTCConnection(RTCSpecHelper::RTC_STATIC_CONFIG)
    expect( connection.get_find_new_query() ).to  eq("dc:type=\"com.ibm.team.apt.workItemType.story\" and #{TestConfig::RTC_EXTERNAL_ID_FIELD}=\"\"")
  end
  
  it "should get a user defined query for finding new items " do
    connection = getRTCConnection(RTCSpecHelper::RTC_QUERY_CONFIG)
    expect( connection.get_find_new_query() ).to  eq("dc:identifier=1 and dc:type=\"com.ibm.team.apt.workItemType.story\" and #{TestConfig::RTC_EXTERNAL_ID_FIELD}=\"\"")
  end
    
end