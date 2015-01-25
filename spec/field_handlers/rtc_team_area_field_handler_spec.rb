# Copyright 2001-2015 Rally Software Development Corp. All Rights Reserved.
require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe 'Team Area Field Handler Tests' do

  team_area_field_name = "rtc_cm:teamArea"
  
  team_area_fieldhandler_config = "
  <RTCTeamAreaFieldHandler>
    <FieldName>#{team_area_field_name}</FieldName>
  </RTCTeamAreaFieldHandler>"

  before(:each) do
    @connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    @unique_number = Time.now.strftime("%Y%m%d%H%M%S") + '-' + Time.now.usec.to_s
  end

  after(:all) do
#    @connection.disconnect() if !@connection.nil?
  end

  it "should return nil if there is no value to transform_out" do
    item = {'dc:title' => 'test title'}

    root = YetiTestUtils::load_xml(team_area_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCTeamAreaFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
  it "should return nil if there the transform_out value is an empty string" do
    item = {'dc:title' => 'test title', team_area_field_name => '' }

    root = YetiTestUtils::load_xml(team_area_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCTeamAreaFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
  it "should throw exception on transform_in" do
    root = YetiTestUtils::load_xml(team_area_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCTeamAreaFieldHandler.new
    fh.read_config(root)
    expect { fh.transform_in("") }.to raise_error(/Not Implemented/)
  end

  it "should correctly transform_out if there is a value to transform" do
    team_area = {
        "rdf:resource"=>"https://#{TestConfig::RTC_URL}/ccm/oslc/teamareas/#{TestConfig::RTC_TEAMAREA_ID}"
    }
      
    item = {'dc:title' => 'test title', team_area_field_name => team_area }

    root = YetiTestUtils::load_xml(team_area_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCTeamAreaFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to eq(TestConfig::RTC_TEAMAREA)
  end

  it "should transform_out a nil if cannot find the project" do
    team_area = {
        "rdf:resource"=>"https://#{TestConfig::RTC_URL}/ccm/oslc/teamareas/ARNOLD"
    }
      
    item = {'dc:title' => 'test title', team_area_field_name => team_area }

    root = YetiTestUtils::load_xml(team_area_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCTeamAreaFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
end
