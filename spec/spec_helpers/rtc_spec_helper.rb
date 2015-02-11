# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.
require File.dirname(__FILE__) + '/spec_helper'
if !File.exist?(File.dirname(__FILE__) + '/test_configuration_helper.rb')
  puts
  puts " You must create a file with your test values at #{File.dirname(__FILE__)}/test_configuration_helper.rb"
  exit 1
end
require File.dirname(__FILE__) + '/test_configuration_helper'

require 'rallyeif-wrk'
require File.dirname(__FILE__) + '/../../lib/rallyeif-rtc'
#  rtc_spec_helper.rb
#

include YetiTestUtils

module RTCSpecHelper

  RTCConnection           = RallyEIF::WRK::RTCConnection          if not defined?(RTCConnection)
  RecoverableException    = RallyEIF::WRK::RecoverableException   if not defined?(RecoverableException)
  UnrecoverableException  = RallyEIF::WRK::UnrecoverableException if not defined?(UnrecoverableException)
  YetiSelector            = RallyEIF::WRK::YetiSelector           if not defined?(YetiSelector)
  FieldMap                = RallyEIF::WRK::FieldMap               if not defined?(FieldMap)
  Connector               = RallyEIF::WRK::Connector              if not defined?(Connector)
  
  RTC_STATIC_CONFIG = "
    <config>
      <RTCConnection>
        <Url>#{TestConfig::RTC_URL}</Url>
        <User>#{TestConfig::RTC_USER}</User>
        <Password>#{TestConfig::RTC_PASSWORD}</Password>
        <ProjectArea>#{TestConfig::RTC_PROJECTAREA}</ProjectArea>
        <ExternalIDField>#{TestConfig::RTC_EXTERNAL_ID_FIELD}</ExternalIDField>
        <ArtifactType>#{TestConfig::RTC_ARTIFACT_TYPE}</ArtifactType>
      </RTCConnection>
    </config>"
  
  RTC_QUERY_CONFIG = "
    <config>
      <RTCConnection>
        <Url>#{TestConfig::RTC_URL}</Url>
        <User>#{TestConfig::RTC_USER}</User>
        <Password>#{TestConfig::RTC_PASSWORD}</Password>
        <ProjectArea>#{TestConfig::RTC_PROJECTAREA}</ProjectArea>
        <ExternalIDField>#{TestConfig::RTC_EXTERNAL_ID_FIELD}</ExternalIDField>
        <ArtifactType>#{TestConfig::RTC_ARTIFACT_TYPE}</ArtifactType>
        <CopyQuery>dc:identifier=1</CopyQuery>
      </RTCConnection>
    </config>"
  
  RTC_MISSING_PROJECT_AREA_CONFIG = "
    <config>
      <RTCConnection>
        <Url>#{TestConfig::RTC_URL}</Url>
        <User>#{TestConfig::RTC_USER}</User>
        <Password>#{TestConfig::RTC_PASSWORD}</Password>
        <ExternalIDField>#{TestConfig::RTC_EXTERNAL_ID_FIELD}</ExternalIDField>
        <ArtifactType>#{TestConfig::RTC_ARTIFACT_TYPE}</ArtifactType>
      </RTCConnection>
    </config>"
    
  RTC_MISSING_ARTIFACT_CONFIG = "
    <config>
      <RTCConnection>
        <Url>url</Url>
        <User>user@company.com</User>
        <Password>Secret</Password>
        <ProjectArea>#{TestConfig::RTC_PROJECTAREA}</ProjectArea>
        <ExternalIDField>#{TestConfig::RTC_EXTERNAL_ID_FIELD}</ExternalIDField>
      </RTCConnection>
    </config>"
  
  RTC_MISSING_URL_CONFIG = "
    <config>
      <RTCConnection>
        <User>user@company.com</User>
        <Password>Secret</Password>
        <ExternalIDField>#{TestConfig::RTC_EXTERNAL_ID_FIELD}</ExternalIDField>
        <ProjectArea>#{TestConfig::RTC_PROJECTAREA}</ProjectArea>
        <ArtifactType>#{TestConfig::RTC_ARTIFACT_TYPE}</ArtifactType>
      </RTCConnection>
    </config>"
  
  RTC_EXTERNAL_FIELDS_CONFIG = "
    <config>
      <RTCConnection>
        <Url>#{TestConfig::RTC_URL}</Url>
        <User>#{TestConfig::RTC_USER}</User>
        <Password>#{TestConfig::RTC_PASSWORD}</Password>
        <IDField>#{TestConfig::RTC_ID_FIELD}</IDField>
        <ProjectArea>#{TestConfig::RTC_PROJECTAREA}</ProjectArea>
        <ExternalIDField>#{TestConfig::RTC_EXTERNAL_ID_FIELD}</ExternalIDField>
        <ExternalEndUserIDField>#{TestConfig::RTC_EXTERNAL_EU_ID_FIELD}</ExternalEndUserIDField>
        <CrosslinkUrlField>#{TestConfig::RTC_CROSSLINK_FIELD}</CrosslinkUrlField>
        <ArtifactType>#{TestConfig::RTC_ARTIFACT_TYPE}</ArtifactType>
      </RTCConnection>
    </config>"
      
  def getRTCConnection(config_file)
    root = YetiTestUtils::load_xml(config_file).root
    connection = RTCConnection.new(root)
    return connection
  end
  
  def RTC_connect(config_file)
    root = YetiTestUtils::load_xml(config_file).root
    connection = RTCConnection.new(root)
    connection.connect()
    return connection
  end

  def rally_connect(config_file)
    root = YetiTestUtils::load_xml(config_file).root
    connection = RallyEIF::WRK::RallyConnection.new(root)
    connection.connect()
    return connection
  end
  
  def remove_RTC_artifact(connection, artifact)
    #TODO
    
  end
  
  def create_RTC_artifact(connection, extra_fields = nil)    
    name = 'Time-' + Time.now.strftime("%Y%m%d%H%M%S") + '-' + Time.now.usec.to_s
    fields            = {}
    fields["dc:title"] = name
      # TODO: fix required field to make it generic.  This is required in current environment:
#      fields["rtc_cm:filedAgainst"] = 
#        "https://dev2developer.aetna.com/ccm/resource/itemOid/com.ibm.team.workitem.Category/_NaEYwGxJEeSXtYeYHu-AxQ"
       fields["rtc_cm:filedAgainst"] = 
         "https://dev2developer.aetna.com/ccm/resource/itemOid/com.ibm.team.workitem.Category/_ohx7gKDDEeSNq699yfGkFw"

    if !extra_fields.nil?
      fields.merge!(extra_fields)
    end
    item = connection.create(fields)
    return [item, item['dc:title']]
  end
  
end
