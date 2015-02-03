require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

describe "When looking for " do
  before(:each) do
    @connection = RTC_connect(RTCSpecHelper::RTC_STATIC_CONFIG)
    @connection.validate()
    @external_id = Time.now.strftime("%Y%m%d%H%M%S") + '-' + Time.now.usec.to_s
    @items_to_remove = []
  end
  
  after(:each) do
    @items_to_remove.each do |item|
      remove_RTC_artifact(@connection,item)
    end
  end
  
  it "items that are new, should find items without a rally id" do
    items_found_before_create = @connection.find_new()
    item,name = create_RTC_artifact(@connection)
    @items_to_remove.push(item)
    
    items_found_after_create = @connection.find_new()
    expect(items_found_after_create.length).to be > items_found_before_create.length
  end
  
  # items that have an external id assigned are not new
  it "items that are new, should not find items with a rally id" do
    items_found_before_create = @connection.find_new()
    item,name = create_RTC_artifact(@connection, { TestConfig::RTC_EXTERNAL_ID_FIELD => @external_id })
    items_found_after_create = @connection.find_new()
    expect(items_found_after_create.length).to eq( items_found_before_create.length )
  end
  
  it "items that are new and using a user-supplied query for title, should find items without a rally id" do
    find_title = "Find me: #{@external_id}"
    @connection.copy_query = "dc:title=\"#{find_title}\""
    
    item,name = create_RTC_artifact(@connection)
    item2,name2 = create_RTC_artifact(@connection,{ "dc:title"=>find_title })
    
    items_found_after_create = @connection.find_new()
    expect(items_found_after_create.length).to eq(1)
  end
  
  it "items that are new and using a user-supplied query for team area, should find items without a rally id" do
#    
    #   "dc:title":"Consumer Business 1.0"

    team_name = "Consumer Business 1.0"
    team_resource_full = "https:\/\/dev2developer.aetna.com\/ccm\/oslc\/teamareas\/_TFK6YWxJEeSXtYeYHu-AxQ"
    team_resource = "_TFK6YWxJEeSXtYeYHu-AxQ"
    filed_against = "https:\/\/dev2developer.aetna.com\/ccm\/resource\/itemOid\/com.ibm.team.workitem.Category\/_kLlowGxJEeSXtYeYHu-AxQ"
    
    find_team = team_resource
    @connection.copy_query = "rtc_cm:teamArea=\"#{find_team}\""
    
    items_found_before_create = @connection.find_new()
    item,name = create_RTC_artifact(@connection)
    item2,name2 = create_RTC_artifact(@connection,{ 
      "rtc_cm:teamArea"=>{ "rdf:resource"=>team_resource_full },
      "rtc_cm:filedAgainst"=>{"rdf:resource"=>filed_against}

    })
    
    items_found_after_create = @connection.find_new()
    expect(items_found_after_create.length).to eq(items_found_before_create.length + 1)
  end
  
  it "items by external id, should not find one item" do
    item,name = create_RTC_artifact(@connection, { TestConfig::RTC_EXTERNAL_ID_FIELD => @external_id })
    item_found = @connection.find_by_external_id(@external_id)
    expect(item_found['dc:title']).to eq( item['dc:title'] )
  end
  
  it "items that are updated, should find items with a rally id" do
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
  
  it "items that are updated, should NOT find items without a rally id" do
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
  
  it "items that are updated, should not find items with a rally id created before check update date" do
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
  
  it "project area id, should find ID when given a valid name" do
    expect( @connection.find_team_area_id(TestConfig::RTC_TEAMAREA) ).to eq(TestConfig::RTC_TEAMAREA_ID)
  end
  
  it "project area id, should return nil when given an invalid name" do
    expect( @connection.find_team_area_id("fred doesn't exist") ).to be_nil
  end
  
  it "project area id, should return nil  when given nil" do
    expect( @connection.find_team_area_id(nil) ).to be_nil
  end
  
  it "project area id, should return nil  when given blank" do
    expect( @connection.find_team_area_id('') ).to be_nil
  end
  
  it "project area name, should find name when given a valid id" do
    expect( @connection.find_team_area_name(TestConfig::RTC_TEAMAREA_ID) ).to eq(TestConfig::RTC_TEAMAREA)
  end
  
  it "project area name, should return nil when given an invalid id" do
    expect( @connection.find_team_area_name("fred doesn't exist") ).to be_nil
  end
  
  it "project area name, should return nil  when given nil" do
    expect( @connection.find_team_area_name(nil) ).to be_nil
  end
  
  it "project area name, should return nil  when given blank" do
    expect( @connection.find_team_area_name('') ).to be_nil
  end
  
  it "project area name, should return name when given a valid url" do
    expect( @connection.find_team_area_name("https://#{TestConfig::RTC_URL}/ccm/process/project-areas/#{TestConfig::RTC_PROJECTAREA_ID}/team-areas/#{TestConfig::RTC_TEAMAREA_ID}") ).to eq(TestConfig::RTC_TEAMAREA)
  end
  
  ## there are multiple URLs that can represent a project
  it "project area name, should return when given an oslc url" do
    expect( @connection.find_team_area_name( "https://#{TestConfig::RTC_URL}/ccm/oslc/teamareas/#{TestConfig::RTC_TEAMAREA_ID}") ).to eq(TestConfig::RTC_TEAMAREA)
  end
  
end