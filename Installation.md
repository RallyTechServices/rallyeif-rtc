##How to Install: Rally - Rational Team Concert Connector

**3 February 2015**

### Overview

The Rally - Rational Team Concert Connector provides single-direction copying and updating of stories from Rational Team Concert (RTC) to Rally.  The connector is a Ruby application that will poll RTC for new and updated records that need to be synchronized with Rally and copy or update the data from configured fields as appropriate.  The application can be configured to "wake up" and poll on its own or run as a cronjob/scheduled task.

The connector is configured via an XML file that has extensive settings, the most important of which are covered in the Connector Configuration section below.

When the connector copies an item from RTC into Rally for the first time, both the RTC item and the Rally item will be given the identifier of the item from the other system.  The value in this external ID field is how the connector knows whether to create a new Rally item or update an existing one.  (The connector is transactional; data is not stored on the file system (aside from the configuration file, a timestamp file and the information in the logs.)  It is possible, then to disconnect items from both systems by deleting the value in this field.  If you wish to delete the Rally item, but retain the RTC item, you must clear this field n the RTC item, otherwise the connector will report errors while trying to update a non-existent item in Rally.

The copying and updating are run as separate "services" and the configuration file can be configured to do only one or the other or both.  It is possible to make and run multiple configuration files if you want to make different rules for the services.

### Pre-Requisites & Configuration Settings

#### Environment

  * The connector is a Ruby application and requires Ruby 2.0 or greater.  It can run on any operating system that supports Ruby.
  * The connector will require network access to both RTC and Rally.  Connections with RTC and Rally are made via HTTPS, so an RTC client is not required (but would probably help with configuration).
  * The machine running the connector must have its clock synchronized with the clock of the RTC server.
  
#### Configuration Settings 

  * In RTC, create a custom field to hold the Rally ID.  This field can be a string or an integer.  The Rally ID that will be stored in this "External ID" field will hold the unique Object ID of the Rally item (not the display (or Formatted ID) identifier).  In our test environment, this field was called "rtc_cm:jirakey".  Fields in RTC are presented with namespacing prefixes in the API and the full name is required.
  * In Rally, create a custom field to hold the RTC ID.  This field can be a string or an integer.  When you create a Rally field, the API name for the configuration file will have spaces and special characters removed (so, "External ID" would be "ExternalID" for the configuration file.)

### Ruby and Gem Installation

Ruby must be installed and accessible. You can verify that Ruby is installed and on the PATH by typing "ruby -v" into a command prompt.

A series of GEMs must also be installed.  The release package should include these files in the "gem" directory.  Expand the zip file and then install the GEMs by using a command prompt to navigate to the GEM directory and then typing "gem install --local *.gem".

  *NOTE*: You can ignore any of the output that starts with 'unable to convert "\x'.
  
Verify that the connector was installed by running this command in the parent installation directory.  

  > ruby ./rally2_rtc_connector.rb --version
  
### Connector Configuration

Copy the example configuration file to a new filename and modify it to fit your environment.  The configuration file is XML.  If node entries require special characters, remember to escape them using CDATA.

The configuration file has four major nodes:

  * *RallyConnection* : This section holds information for connecting to Rally, as well as the Rally field information.
  * *RTCConnection* : This section holds information for connecting to RTC, as well as the RTC field information
  * *Connector* : This is the section that will most often be changed as your needs evolve.  This section has two major subsections:
    * *FieldMapping* : This section maps each RTC field to the Rally field that will hold the necessary information.
    * *OtherFieldHandlers* : Field handlers are special snippets of code that can perform transformations on the data coming out of RTC.  Any enumerated field is likely to require a field handler.  
  * *ConnectorRunner* : This section holds information about running the connector, including the logging verbosity level, whether to run in preview mode, and which services to execute
  
Each section's nodes are described in detail below

#### RallyConnection
This section holds information for connecting to Rally, as well as the Rally field information.

  * Url : The web address of the Rally instance.  It is the same as available in the browser to users.  Do not include "https://".  Most often, this will be "rally1.rallydev.com".
  * WorkspaceName : The name of the workspace in Rally that holds the projects that will receive data.
  * Projects : For this particular connector, simply put the name of the top-level project into the <Project> subnode. In Rally, the term "project" is used in the back end to indicate any of the nodes on the team/release train tree.
  * User : The Rally user.  This user must have editor rights in any project that might receive a user story.  Rally user names are always formatted as email addresses.  If you are using SSO, you must whitelist this user and provide it with a password.
  * Password : The Rally user's password.  After the connector is executed the first time, it will modify the configuration file to obfuscate the password to look something like "encoded-V-s-G-s-b-H-l-P-T=-". 
  * ArtifactType : The Rally record type that will hold the data.  It is possible to send RTC items into Defects; however, a User Story is the likely record type.  ("HierarchicalRequirement" is an alias for User Story.)
  * ExternalIDField : The name of the field in Rally that will hold the ID of the source object from RTC.
  
#### RTCConnection

  * Url : The web address of the RTC instance.  Do not include "https://".  In development, we used "dev2developer.aetna.com".  
  * User : A user ID to access RTC.
  * Password : This RTC user's password.  After the connector is executed the first time, it will modify the configuration file to obfuscate the password to look something like "encoded-V-s-G-s-b-H-l-P-T=-". 
  * ArtifactType : The type of object to copy from RTC.  This is for future development to allow for other record types to use the same engine.  A story in RTC is called a "planItem" in the API.
  * Project Area : The project area from which to copy data.  Team Areas are associated to Rally projects in the FieldMapping section below.  In development, we used "Next Gen Platform - Vision 2020 - SAFe"
  * ExternalIDField : The name of the custom field created above to hold the ID of the Rally object that gets created.
  * CopyQuery : This is optional.  You can put an RTC query expression to restrict the items that will be initially copied.  Queries must be made in the format of an RTC query (e.g., rtc_cm:teamArea="_TFK6YWxJEeSXtYeYHu-AxQ".  You can find the team area ID by using the included find_team_id.rb file (type ruby find_team_id.rb <config file> <team name>))
  
#### Connector

##### FieldMapping

Each field mapping in this section is a Field node that contains the Rally field name and the RTC field name.  The RTC field name is put into the <Other> node.  Fields in RTC are presented with namespacing prefixes in the API and the full name is required.  So, for example, mapping the RTC Summary to Rally Name is actually mapping from the RTC field called "dc:title" in the API.  That will look like:

    <Field><Rally>Name</Rally><Other>dc:title</Other></Field>

Most likely, custom fields will be prefixed by "rtc_cm:".  The RTC Size field has a very long name, so to map it to projects, use:

      <Field><Rally>PlanEstimate</Rally><Other>rtc_cm:com.ibm.team.apt.attribute.complexity</Other></Field>

*Recommendation* : We suggest starting with the minimum system required fields to validate and then building up to the desired set of fields, one at a time while configuring, to make troubleshooting easiest.  In addition, we really recommend copying only the fields that are absolutely needed for whatever reporting activities are planned.

##### OtherFieldHandlers

Fields that require special handling can be further configured in this section.  For fields that are straight strings or numbers, for the most part, the field mapping above is enough.  However, for fields that have a dropdown, RTC presents the data as an enumeration value, so a fieldhandler is required to interpret the data and turn it into something that Rally will recognize.  Field handlers written for this project are available below.  It is possible to write further field handlers using Ruby and drop them into the 'field_handlers' folder without modifying the core code base.  

Fields that require handling still *must* be listed in the FieldMapping section above.  

Only one outer node called <OtherFieldHandlers> is required.  Each of the following can be a node inside.

  * RTCComplexityFieldHandler : For the size field, converts the size into a number for Rally.  This handler has a single node called FieldName.  Put the complexity/size field name (rtc_cm:com.ibm.team.apt.attribute.complexity) in here.  
  * RTCResourceFieldHandler : For team area and state and other fields that are identified by a link to another list, use this handler to convert to a string (or to some field on the other object).  With state and teamArea, we want the dc:title field, which you put into the ReferencedFieldLookupID field.  (The base field name from the actual story goes into the FieldName node.)
  * RTCLinkFieldHandler : For fields (like parent) that are identified by a link but saved in RTC as an array
  
  *NOTES*: 
  	* When using RTCResourceFieldHandler for TeamArea, the string for the name of the Team Area will be provided and matched automatically by the Rally connection to select a project.  In cases where the string that pops out of this field handler don't match values in Rally, use a further field handler on the Rally side to map (as in the example provided for ScheduleState).
  	* When Using RTCLinkFieldHandler for Parent/Portfolio Item, if the portfolio item's ObjectID isn't being used -- that is, the value on the parent in RTC shows the Formatted ID of the Rally item, it's necessary to also have a handler on the Rally side to convert the FormattedID into an actual portfolio item by reference, so include that below.
##### RallyFieldHandlers

It is possible that fields that were handled on the RTC side will still have a value that is not useful for Rally.  These values can be further refined using a Rally field handler.  As an example, a RTC field handler can convert the State to a string, but the string needs to be further mapped to a Rally value.  

  * RallyEnumFieldHandler : For drop-down values in Rally that require a particular set of values that are not necessarily the same as values in RTC, use this handler to provide an array of value mappings.   
    ** FieldName : contains the name of the RALLY field
    ** Mappings : provide a series of <Field> nodes that contain a value for the Rally side mapped to a value on the RTC side (using <Other>)
  * RallyReferenceFieldHandler : Like the RTCResourceFieldHandler, used to find the referenced object via query on a unique field's value that might be provided by RTC
    ** FieldName : contains the name of the Rally field that will hold the relationship (e.g., PortfolioItem)
    ** ReferencedFieldLookupID : the field on the referenced item that can be used for querying, usually FormattedID

#### ConnectorRunner

This section holds information about running the connector.

  * LogLevel : The connector will output to a file called rallylog.log.  The verbosity levels available are DEBUG, INFO, WARN, ERROR.  
  * Preview : A 'true' value will have the connector log into both systems and list out the items that would be copied or updated, but will only do the copying/updating if this is set to 'false.'
  * Services : There are two services available.  They can be listed with a comma seperator. 
    * COPY\_RTC\_TO\_RALLY : this service copies items that are in RTC that have not yet been created in Rally.  (That is, only items in RTC that do not have a value in the External ID field.)
    * UPDATE\_RTC\_TO\_RALLY : this service finds RTC items that have been modified since the last run of the connector (there is a time file stored locally) and copies changed data in the configured fields to the associated item in Rally.  This service only operates against items that have already been created in Rally. (That is, only items in RTC that *do* have a value in the External ID field.)

### Execution/Running the Connector

To execute the connector, we suggest first configuring the configuration file with Preview set to 'true'.  This will allow you to verify that the connection information is correct.  

The connector can be configured to run once and end.  This is the common configuration for setting up as a scheduled task or cronjob.  To execute this way, open a command prompt, navigate to the installation directory and type:

    > ruby rally2_rtc_connector.rb my_config_file.xml -1
    
replacing "my_config_file.xml" with the file you made.  Multiple configuration files can be run on the same line; they'll be executed in order.  (You might do this if you want different fields updated than were copied, for example.)

    > ruby  rally2_rtc_connector.rb  ConfigFile1.xml  ConfigFile2.xml  -1

When running with a cronjob/scheduled task, make sure that the user executing via the task/job has Ruby in the path and can read and write the installation directory (because logs, time file, and the xml file are modified by the connector when running).  

**DO NOT** Invoke the connector as separate tasks/jobs in the same directory because the connector will always write to the same log files and two processes trying to write to the same file can cause conflict on some platforms (not to mention it'll be harder to read interleaved log files).  When testing/configuring, make sure that the connector isn't also running under some other process/job so that you don't run into confusing log information.

To have the connector decide when to wake up and re-run, pass a number of minutes between runs instead of -1.  The connector will execute and then sleep for that number of minutes.  Do not combine this mechanism with cronjob/scheduled task.

    > ruby rally2_rtc_connector.rb my_config_file.xml 15
