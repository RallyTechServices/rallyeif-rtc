# Copyright 2001-2015 Rally Software Development Corp. All Rights Reserved.
require File.dirname(__FILE__) + '/../spec_helpers/spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/rtc_spec_helper'

include RTCSpecHelper
include YetiTestUtils

# RTC Links are used for parent-child relationships

describe 'Parent Link Field Handler Tests' do

  # a link looks like:
  #  "rtc_cm:com.ibm.team.workitem.linktype.parentworkitem.parent":[
  #      {
  #        "rtc_cm:com.ibm.team.workitem.linktype.relatedworkitem.related":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.schedulePredecessor.predecessor":[]
  #        "rtc_cm:com.ibm.team.filesystem.workitems.change_set.com.ibm.team.scm.ChangeSet":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.blocksworkitem.dependsOn":[]
  #        "calm:relatedTestPlan":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.textualReference.textuallyReferenced":[]
  #        "rtc_cm:com.ibm.team.apt.attribute.complexity":{
  #          "rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/enumerations\/_NHtogaDCEeSNq699yfGkFw\/complexity\/0"
  #        }
  #        "rtc_cm:com.ibm.team.workitem.linktype.copiedworkitem.copies":[]
  #        "calm:relatedTestCase":[]
  #        "calm:relatedRequirement":[]
  #        "rtc_cm:archived":false
  #        "rtc_cm:plannedFor":null
  #        "rtc_cm:resolvedBy":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/jts\/users\/unassigned"}
  #        "rtc_cm:com.ibm.team.workitem.linktype.schedulePredecessor.successor":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.relatedartifact.relatedArtifact":[]
  #        "rtc_cm:ProjectSR":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/enumerations\/_NHtogaDCEeSNq699yfGkFw\/projectSR\/projectSR.literal.l2"}
  #        "rtc_cm:comments":[]
  #        "oslc_cm:severity":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/enumerations\/_NHtogaDCEeSNq699yfGkFw\/severity\/severity.literal.l3"}
  #        "rtc_cm:resolved":null
  #        "calm:relatedTestScript":[]
  #        "dc:creator":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/jts\/users\/N741973"}
  #        "dc:subject":""
  #        "rtc_cm:com.ibm.team.enterprise.promotion.linktype.promotionBuildResult.promotionBuildResult":[]
  #        "rtc_cm:progressTracking":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/workitems\/_jWpSgKaZEeSTofGV7u1HVg\/progressTracking"}
  #        "rtc_cm:contextId":"_NHtogaDCEeSNq699yfGkFw"
  #        "rtc_cm:com.ibm.team.connector.ccbridge.common.ver2wi.s":[]
  #        "rtc_cm:startDate":null
  #        "calm:tracksChanges":[]
  #        "calm:tracksRequirement":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.parentworkitem.parent":[]
  #        "rtc_cm:com.ibm.team.build.linktype.includedDeployments.com.ibm.team.build.common.link.includedInDeployment":[]
  #        "rtc_cm:com.ibm.team.enterprise.promotion.linktype.promotionDefinition.promotionDefinition":[]
  #        "oslc_cm:label":"158883: This is a feature"
  #        "rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/resource\/itemName\/com.ibm.team.workitem.WorkItem\/158883"
  #        "dc:type":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/types\/_NHtogaDCEeSNq699yfGkFw\/Feature"}
  #        "calm:relatedTestSuite":[]
  #        "calm:relatedExecutionRecord":[]
  #        "rtc_cm:estimate":null
  #        "rtc_cm:resolution":null
  #        "oslc_cm:trackedWorkItem":[]
  #        "dc:modified":"2015-01-28T03:00:31.596Z"
  #        "rtc_cm:com.ibm.team.connector.scm.common.linkType.importerDependency.t":[]
  #        "rtc_cm:ownedBy":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/jts\/users\/unassigned"}
  #        "rtc_cm:com.ibm.team.apt.attribute.acceptance":""
  #        "rtc_cm:filedAgainst":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/resource\/itemOid\/com.ibm.team.workitem.Category\/_ohx7gKDDEeSNq699yfGkFw"}
  #        "rtc_cm:com.ibm.team.workitem.linktype.duplicateworkitem.duplicates":[]
  #        "oslc_pl:schedule":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/workitems\/_jWpSgKaZEeSTofGV7u1HVg\/schedule"}
  #        "rtc_cm:com.ibm.team.enterprise.deployment.linktype.deploymentBuildResult.packageBuildResult":[]
  #        "rtc_cm:com.ibm.team.enterprise.promotion.linktype.resultWorkItem.promoted":[]
  #        "rtc_cm:com.ibm.team.scm.svn.linkType.workItem.s":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.duplicateworkitem.duplicateOf":[]
  #        "rtc_cm:jirakey":"F319"
  #        "dc:description":""
  #        "rtc_cm:due":null
  #        "dc:identifier":158883
  #        "rtc_cm:com.ibm.team.build.linktype.includedPackages.com.ibm.team.build.common.link.includedInPackages":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.resolvesworkitem.resolvedBy":[]
  #        "rtc_cm:com.ibm.team.enterprise.promotion.linktype.promotedChangeSets.promotedChangeSets":[]
  #        "rtc_cm:release":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/enumerations\/_NHtogaDCEeSNq699yfGkFw\/release\/release.literal.l2"}
  #        "rtc_cm:com.ibm.team.enterprise.packaging.linktype.resultWorkItem.promoted":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.parentworkitem.children":[{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/resource\/itemName\/com.ibm.team.workitem.WorkItem\/158881"
  #        "oslc_cm:label":"158881: I am a new item"}]
  #        "oslc_cm:tracksWorkItem":[]
  #        "calm:implementsRequirement":[]
  #        "rtc_cm:subscribers":[{"rdf:resource":"https:\/\/dev2developer.aetna.com\/jts\/users\/N741973"}]
  #        "rtc_cm:com.ibm.team.enterprise.promotion.linktype.promotedBuildMaps.promotedBuildMaps":[]
  #        "rtc_cm:com.ibm.team.connector.scm.common.linkType.tracksUcmObject.t":[]
  #        "dc:title":"This is a feature"
  #        "rtc_cm:state":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/workflows\/_NHtogaDCEeSNq699yfGkFw\/states\/com.ibm.team.apt.epic.workflow\/com.ibm.team.apt.epic.workflow.state.s1"}
  #        "rtc_cm:timeSheet":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/workitems\/_jWpSgKaZEeSTofGV7u1HVg\/rtc_cm:timeSheet"}
  #        "rtc_cm:com.ibm.team.build.linktype.includedWorkItems.com.ibm.team.build.common.link.includedInBuilds":[]
  #        "calm:testedByTestCase":[]
  #        "rtc_cm:solution":""
  #        "rtc_cm:com.ibm.team.connector.ccbridge.common.act2wi.s":[]
  #        "rtc_cm:timeSpent":null
  #        "rtc_cm:com.ibm.team.enterprise.promotion.linktype.resultWorkItem.result":[]
  #        "oslc_cm:relatedChangeManagement":[]
  #        "rtc_cm:modifiedBy":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/jts\/users\/N741973"}
  #        "calm:elaboratedByArchitectureElement":[]
  #        "rtc_cm:teamArea":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/teamareas\/_O4JO4aDDEeSNq699yfGkFw"}
  #        "rtc_cm:com.ibm.team.workitem.linktype.blocksworkitem.blocks":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.attachment.attachment":[]
  #        "rtc_cm:com.ibm.team.enterprise.package.linktype.packageDefinition.packageDefinition":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.copiedworkitem.copiedFrom":[]
  #        "oslc_cm:priority":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/enumerations\/_NHtogaDCEeSNq699yfGkFw\/priority\/priority.literal.l01"}
  #        "rtc_cm:com.ibm.team.enterprise.packaging.linktype.resultWorkItem.result":[]
  #        "rtc_cm:com.ibm.team.enterprise.package.linktype.packageBuildResult.packageBuildResult":[]
  #        "rtc_cm:projectArea":{"rdf:resource":"https:\/\/dev2developer.aetna.com\/ccm\/oslc\/projectareas\/_NHtogaDCEeSNq699yfGkFw"}
  #        "rtc_cm:foundIn":null
  #        "calm:blocksTestExecutionRecord":[]
  #        "rtc_cm:correctedEstimate":null
  #        "calm:affectsPlanItem":[]
  #        "rtc_cm:com.ibm.team.workitem.linktype.resolvesworkitem.resolves":[]
  #        "rtc_cm:com.ibm.team.enterprise.deployment.linktype.deploymentDefinition.packageDefinition":[]
  #        "rtc_cm:com.ibm.team.build.linktype.reportedWorkItems.com.ibm.team.build.common.link.reportedAgainstBuilds":[]
  #        "dc:created":"2015-01-28T03:00:31.542Z"
  #        "calm:affectsExecutionResult":[]
  #        "calm:affectedByDefect":[]
  #      }]
  
  mapped_field_name = "rtc_cm:com.ibm.team.workitem.linktype.parentworkitem.parent"
  referenced_field_name = "rtc_cm:jirakey"
  
  fieldhandler_config = "
  <RTCParentLinkFieldHandler>
    <FieldName>#{mapped_field_name}</FieldName> <!-- the field on the story -->
    <ReferencedFieldLookupID>#{referenced_field_name}</ReferencedFieldLookupID>  <!-- the field on the thing that's at the other end of the reference pointer -->
    <LimitType>Feature</LimitType>  <!-- the type of parent we want to look for 
  </RTCParentLinkFieldHandler>"

  fieldhandler_with_climb = "
  <RTCParentLinkFieldHandler>
    <FieldName>#{mapped_field_name}</FieldName> <!-- the field on the story -->
    <ReferencedFieldLookupID>#{referenced_field_name}</ReferencedFieldLookupID>  <!-- the field on the thing that's at the other end of the reference pointer -->
    <LimitType>Feature</LimitType>  <!-- the type of parent we want to look for 
    <Climb>true</Climb> <!-- if true and the parent isn't the limit type, check its parent, and keep climbing until type found -->'
  </RTCParentLinkFieldHandler>"
  
  
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
    fh = RallyEIF::WRK::FieldHandlers::RTCLinkFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
  it "should return nil if there the transform_out value is an empty string" do
    item = {'dc:title' => 'test title', mapped_field_name => '' }

    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCLinkFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
    
  it "should return nil if there the transform_out value is an empty array" do
    item = {'dc:title' => 'test title', mapped_field_name => [] }

    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCLinkFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
  it "should throw exception on transform_in" do
    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCLinkFieldHandler.new
    fh.read_config(root)
    expect { fh.transform_in("") }.to raise_error(/Not Implemented/)
  end

  it "should correctly transform_out if there is a value to transform" do
    field_value = [{
        "rdf:resource"=>"https://#{TestConfig::RTC_URL}/ccm/oslc/whatever/whatever",
        "dc:title" => "Wilma",
        referenced_field_name => "Fred"
    }]
      
    item = {'dc:title' => 'test title', mapped_field_name => field_value }

    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCLinkFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to eq("Fred")
  end

  it "should transform_out a nil if cannot find item with the reference field" do
    field_value = [{
        "rdf:resource"=>"https://#{TestConfig::RTC_URL}/ccm/oslc/teamareas/ARNOLD"
    }]
      
    item = {'dc:title' => 'test title', mapped_field_name => field_value }

    root = YetiTestUtils::load_xml(fieldhandler_config).root
    fh = RallyEIF::WRK::FieldHandlers::RTCLinkFieldHandler.new
    fh.connection = @connection
    fh.read_config(root)
    expect( fh.transform_out(item) ).to be_nil
  end
  
end
