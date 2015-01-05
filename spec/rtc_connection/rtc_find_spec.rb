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
end