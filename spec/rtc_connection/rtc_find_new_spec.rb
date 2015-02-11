require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe "When looking for new items" do
  before(:each) do
    @connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    @items_to_remove = []
  end
  
  after(:each) do
    @items_to_remove.each do |item|
      # remove item
    end
  end
  
  it "should create 2000 stories" do
    (1..2000).each do |idx|
      puts idx
      item,name = create_RTC_artifact(@connection)
    end
  end
  
  it "should find items without a rally id" do
    items_found_before_create = @connection.find_new()
    item,name = create_RTC_artifact(@connection)
    items_found_after_create = @connection.find_new()
    expect(items_found_after_create.length).to be > items_found_before_create.length
  end
  
  it "should not find items with a rally id" do

  end
  
end