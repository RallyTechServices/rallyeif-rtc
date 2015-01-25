require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe "When looking for items" do
  before(:each) do
    @connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    @connection.validate()
    @external_id = Time.now.strftime("%Y%m%d%H%M%S") + '-' + Time.now.usec.to_s
    @items_to_remove = []
  end
  
  after(:each) do
    @items_to_remove.each do |item|
      # remove item
    end
  end
  
  it "that are new, should find items without a rally id" do
    items_found_before_create = @connection.find_new()
    item,name = create_RTC_artifact(@connection)
    items_found_after_create = @connection.find_new()
    expect(items_found_after_create.length).to be > items_found_before_create.length
  end
  
  # items that have an external id assigned are not new
  it "that are new, should not find items with a rally id" do
    items_found_before_create = @connection.find_new()
    item,name = create_RTC_artifact(@connection, { TestConfig::RTC_EXTERNAL_ID_FIELD => @external_id })
    items_found_after_create = @connection.find_new()
    expect(items_found_after_create.length).to eq( items_found_before_create.length )
  end
  
  it "by external id, should not find one item" do
    item,name = create_RTC_artifact(@connection, { TestConfig::RTC_EXTERNAL_ID_FIELD => @external_id })
    item_found = @connection.find_by_external_id(@external_id)
    expect(item_found['dc:title']).to eq( item['dc:title'] )
  end
  
  it "that are updated, should find items with a rally id" do
    time = (Time.now()).utc
    items_found_before_create = @connection.find_updates(time)
        
    item,name = create_RTC_artifact(@connection, { TestConfig::RTC_EXTERNAL_ID_FIELD => @external_id })
   
    items_found_after_create = @connection.find_updates(time)

    expect(items_found_before_create.length).to be < (items_found_after_create.length)
        
    found_me = false
    items_found_after_create.each do |found_item|
      if @connection.get_value(found_item,'dc:title') == name
        found_me = true
      end
    end
    expect(found_me).to eq(true)
  end
  
  it "that are updated, should NOT find items without a rally id" do
    time = (Time.now()).utc
    items_found_before_create = @connection.find_updates(time)
        
    item,name = create_RTC_artifact(@connection)
   
    items_found_after_create = @connection.find_updates(time)

    expect(items_found_before_create.length).to eq(items_found_after_create.length)
        
    found_me = false
    items_found_after_create.each do |found_item|
      if @connection.get_value(found_item,'dc:title') == name
        found_me = true
      end
    end
    expect(found_me).to eq(false)
  end
  
  it "that are updated, should not find items with a rally id created before check update date" do
    before_item,before_name = create_RTC_artifact(@connection, { TestConfig::RTC_EXTERNAL_ID_FIELD => @external_id })

    sleep(1)
    after_item,after_name = create_RTC_artifact(@connection, { TestConfig::RTC_EXTERNAL_ID_FIELD => @external_id })

    after_item_time = @connection.get_value(after_item,'dc:modified')
    # convert into the style of time saved in the timestamp file
    time = after_item_time.gsub(/\..*Z/,"").gsub(/T/," ")
    
    items_found = @connection.find_updates(time)
        
    found_before_item = false
    found_after_item = false
    items_found.each do |found_item|
      if @connection.get_value(found_item,'dc:title') == before_name
        found_before_item = true
      end
      if @connection.get_value(found_item,'dc:title') == after_name
        found_after_item = true
      end
    end
    expect(found_before_item).to eq(false)
    expect(found_after_item).to eq(true)
  end
  
end