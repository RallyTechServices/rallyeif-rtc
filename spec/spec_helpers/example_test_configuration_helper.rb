module TestConfig

  # MAKE YOUR OWN VERSION OF THIS and name it 
  # test_configuration_helper.rb
  #
  # DO NOT CHECK IT IN
  
  #
  #
  # rally connection information
  RALLY_USER      = "someone@somewhere.com"
  RALLY_USER_OID  = "123456"  #for slow testing of UserTransformer
  RALLY_PASSWORD  = "secret"
  RALLY_URL       = "demo01.rallydev.com"
  RALLY_WORKSPACE = "Integrations"
  
  # rally configurable information for testing
  # choose a place where we can put lots and lots and lots of 
  # defects and stories.  You can always close these projects later
  RALLY_EXTERNAL_ID_FIELD = "ExternalID"
  RALLY_PROJECT_1         = "Payment Team"
  RALLY_PROJECT_1_OID     = "723161" # Object ID of Project_1
  RALLY_PROJECT_2         = "Shopping Team"
  
  # rally projects in a hierarchical tree for hierarchy tests
  RALLY_PROJECT_HIERARCHICAL_PARENT     = "Online Store"
  RALLY_PROJECT_HIERARCHICAL_CHILD      = "Reseller Site"
  RALLY_PROJECT_HIERARCHICAL_GRANDCHILD = "Reseller Portal Team"
  
  # rtc connection information
  RTC_URL      = "na16.salesforce.com"
  RTC_USER     = ""
  RTC_PASSWORD = ""
  RTC_PROJECTAREA = ""
  RTC_PROJECTAREA_ID = "" # the internal ID of the project area (looks like "_asES3Easdf"
  
  # 
  RTC_EXTERNAL_ID_FIELD    = "rtc_cm:features"
  RTC_EXTERNAL_EU_ID_FIELD = "RallyFormattedID__c"
  RTC_ID_FIELD             = "dc:identifier"
  RTC_CROSSLINK_FIELD      = "RallyURL__c"
  RTC_ARTIFACT_TYPE        = "planItem"

end