# Copyright 2001-2015 Rally Software Development Corp. All Rights Reserved.
require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe 'Complexity Field Handler Tests' do

  class TestConnection < RallyEIF::WRK::Connection
    def name()
      return ""
    end

    def version()
      return ""
    end
  end

  complexity_field_name = "rtc_cm:com.ibm.team.apt.attribute.complexity"
  
  complexity_fieldhandler_config = "
  <RTCComplexityFieldHandler>
    <FieldName>#{complexity_field_name}</FieldName>
  </RTCComplexityFieldHandler>"

  before(:each) do
    @connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    # @connection.validate()
    @unique_number = Time.now.strftime("%Y%m%d%H%M%S") + '-' + Time.now.usec.to_s
    @items_to_remove = []
  end

  after(:all) do
#    @connection.disconnect() if !@connection.nil?
  end

  it "should return nil if there is no value to transform_out" do
    item = {'dc:title' => 'test title'}

    root = YetiTestUtils::load_xml(complexity_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCComplexityFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
  it "should return nil if there the transform_out value is an empty string" do
    item = {'dc:title' => 'test title', complexity_field_name => '' }

    root = YetiTestUtils::load_xml(complexity_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCComplexityFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  

  it "should throw exception on transform_in" do
    root = YetiTestUtils::load_xml(complexity_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCComplexityFieldHandler.new
    fh.read_config(root)
    expect { fh.transform_in("") }.to raise_error(/Not Implemented/)
  end


  it "should correctly transform_out if there is a value to transform" do
    thirteen = {
        "rdf:resource"=>"https://dev2developer.aetna.com/ccm/oslc/enumerations/_NHtogaDCEeSNq699yfGkFw/complexity/13"
    }
    item = {'dc:title' => 'test title', complexity_field_name => thirteen }

    root = YetiTestUtils::load_xml(complexity_fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCComplexityFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to eq(13)
  end

end
