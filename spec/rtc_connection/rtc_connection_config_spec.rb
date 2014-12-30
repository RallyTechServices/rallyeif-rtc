require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe "Given configuration in the RTCConnection section," do
  before(:all) do
    #
  end
   
  it "should successfully load basic config settings " do
    RTC_connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    RTC_connection.artifact_type.should == TestConfig::RTC_ARTIFACT_TYPE.downcase.to_sym
  end
  
  it "should successfully validate a basic config file " do
    RTC_connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    RTC_connection.validate.should be_true
  end
  
  it "should reject missing required fields" do
    expect { RTC_connect(RTCSpecHelper::RTC_MISSING_ARTIFACT_CONFIG) }.to raise_error(/ArtifactType must not be null/)
    expect { RTC_connect(RTCSpecHelper::RTC_MISSING_URL_CONFIG) }.to raise_error(/Url must not be null/)
  end
  
  it "should reject invalid artifact types" do
    fred_artifact_config = YetiTestUtils::modify_config_data(
                            RTCSpecHelper::RTC_STATIC_CONFIG,           #1 CONFIG  - The config file to be augmented
                            "RTCConnection",                                   #2 SECTION - XML element of CONFIG to be augmented
                            "ArtifactType",                                           #3 NEWTAG  - New tag name in reference to REFTAG
                            "Fred",                                                   #4 VALUE   - New value to put into NEWTAG
                            "replace",                                                #5 ACTION  - [before, after, replace, delete]
                            "ArtifactType")                                           #6 REFTAG  - Existing tag in SECTION
    expect { RTC_connect(fred_artifact_config) }.to raise_error(/Could not find <ArtifactType>/)
  end
  
  it "should be OK with tags named <ExternalEndUserIDField>, <CrosslinkUrlField> and <IDField>" do
    # Checking <ExternalEndUserIDField>
    RTC_connection = RTC_connect(RTCSpecHelper::RTC_EXTERNAL_FIELDS_CONFIG)
    RTC_connection.external_end_user_id_field.should == TestConfig::RTC_EXTERNAL_EU_ID_FIELD.to_sym
    RTC_connection.external_item_link_field.should == TestConfig::RTC_CROSSLINK_FIELD.to_sym
    RTC_connection.id_field.should == TestConfig::RTC_ID_FIELD.to_sym
  end
  
  it "should be OK with missing <ExternalEndUserIDField>, <CrosslinkUrlField> and <IDField>" do
    # Checking <ExternalEndUserIDField>
    RTC_connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    RTC_connection.external_end_user_id_field.should be_nil
    RTC_connection.external_item_link_field.should be_nil
    RTC_connection.id_field.should be_nil
  end
    
end