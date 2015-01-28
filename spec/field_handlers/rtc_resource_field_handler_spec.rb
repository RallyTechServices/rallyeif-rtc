# Copyright 2001-2015 Rally Software Development Corp. All Rights Reserved.
require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

# RTC Resources are similar to Rally Reference Fields (They have a url and if
# asked nicely, additional fields.  We're going to default to getting the title
# of these fields
describe 'Resource Field Handler Tests' do

  resource_field_name = "rtc_cm:state"
  
  fieldhandler_config = "
  <RTCResourceFieldHandler>
    <FieldName>#{resource_field_name}</FieldName> <!-- the field on the story or other item -->
    <ReferencedFieldLookupID>dc:title</ReferencedFieldLookupID>  <!-- the story on the thing that's at the other end of the reference pointer -->
  </RTCResourceFieldHandler>"

  before(:each) do
    @connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    @unique_number = Time.now.strftime("%Y%m%d%H%M%S") + '-' + Time.now.usec.to_s
  end

  after(:all) do
#    @connection.disconnect() if !@connection.nil?
  end

  it "should return nil if there is no value to transform_out" do
    item = {'dc:title' => 'test title'}

    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCResourceFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
  it "should return nil if there the transform_out value is an empty string" do
    item = {'dc:title' => 'test title', resource_field_name => '' }

    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCResourceFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
  it "should throw exception on transform_in" do
    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCResourceFieldHandler.new
    fh.read_config(root)
    expect { fh.transform_in("") }.to raise_error(/Not Implemented/)
  end

  it "should correctly transform_out if there is a value to transform" do
    field_value = {
        "rdf:resource"=>"https://#{TestConfig::RTC_URL}/ccm/oslc/whatever/whatever",
        "dc:title" => "Fred"
    }
      
    item = {'dc:title' => 'test title', resource_field_name => field_value }

    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCResourceFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to eq("Fred")
  end

  it "should transform_out a nil if cannot find the reference field" do
    field_value = {
        "rdf:resource"=>"https://#{TestConfig::RTC_URL}/ccm/oslc/teamareas/ARNOLD"
    }
      
    item = {'dc:title' => 'test title', resource_field_name => field_value }

    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCResourceFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
end
