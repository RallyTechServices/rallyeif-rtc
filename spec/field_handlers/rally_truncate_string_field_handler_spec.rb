# Copyright 2001-2015 Rally Software Development Corp. All Rights Reserved.
require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe 'Truncate String Field Handler Tests' do

  before(:each) do
    @connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    @unique_number = Time.now.strftime("%Y%m%d%H%M%S") + '-' + Time.now.usec.to_s
  end

  after(:all) do
#    @connection.disconnect() if !@connection.nil?
  end

  it "should return nil if there is no value to transform_in" do
    @field_name = "Name"
    @size = 25
    fieldhandler_config = "
      <RallyTruncateStringFieldHandler>
        <FieldName>#{@field_name}</FieldName>
        <Size>#{@size}</Size>
      </RallyTruncateStringFieldHandler>"
 
    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RallyTruncateStringFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_in(nil) ).to be_nil
  end
  
  it "should recognize the size when provided" do
    fieldhandler_config = "
            <RallyTruncateStringFieldHandler>
              <FieldName>Name</FieldName>
              <Size>25</Size>
            </RallyTruncateStringFieldHandler>"
            
    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RallyTruncateStringFieldHandler.new
    fh.read_config(root)
     
    expect(fh.size).to eq(25)
                 
  end

    
  it "should provide default size when not provided" do
    fieldhandler_config = "
            <RallyTruncateStringFieldHandler>
              <FieldName>Name</FieldName>
            </RallyTruncateStringFieldHandler>"
            
    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RallyTruncateStringFieldHandler.new
    fh.read_config(root)

    expect(fh.size).to eq(32768)
                 
  end
            
      
    it "should fail if size is not a number" do
      fieldhandler_config = "
              <RallyTruncateStringFieldHandler>
                <FieldName>Name</FieldName>
                <Size>x25</Size>
              </RallyTruncateStringFieldHandler>"
              
      root = YetiTestUtils::load_xml(fieldhandler_config).root
      fh = RallyEIF::WRK::FieldHandlers::RallyTruncateStringFieldHandler.new
      fh.read_config(root)
              
      expect(fh.size).to eq(32768)
                   
    end
              
                
  it "should return full name when under size on transform_in" do
      @field_name = "Name"
      @size = 25
      fieldhandler_config = "
        <RallyTruncateStringFieldHandler>
          <FieldName>#{@field_name}</FieldName>
          <Size>#{@size}</Size>
        </RallyTruncateStringFieldHandler>"
   
  
      root = YetiTestUtils::load_xml(fieldhandler_config).root
      fh = RallyEIF::WRK::FieldHandlers::RallyTruncateStringFieldHandler.new
      fh.connection = @connection
      fh.read_config(root)
      expect( fh.transform_in('test title')).to eq("test title")
    end
    
    it "should return truncated name when over size on transform_in" do
        @field_name = "Name"
        @size = 5
        fieldhandler_config = "
          <RallyTruncateStringFieldHandler>
            <FieldName>#{@field_name}</FieldName>
            <Size>#{@size}</Size>
          </RallyTruncateStringFieldHandler>"
         
        root = YetiTestUtils::load_xml(fieldhandler_config).root
        fh = RallyEIF::WRK::FieldHandlers::RallyTruncateStringFieldHandler.new
        fh.connection = @connection
        fh.read_config(root)
        expect( fh.transform_in('abcdefghijklmnopqrstuvwxyz') ).to eq("abcde")
      end  
end
