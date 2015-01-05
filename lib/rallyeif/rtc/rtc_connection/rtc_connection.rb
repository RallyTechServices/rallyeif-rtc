# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.
require 'httpclient'
require 'rallyeif-wrk'

RecoverableException   = RallyEIF::WRK::RecoverableException if not defined?(RecoverableException)
UnrecoverableException = RallyEIF::WRK::UnrecoverableException
RallyLogger            = RallyEIF::WRK::RallyLogger
XMLUtils               = RallyEIF::WRK::XMLUtils

module RallyEIF
  module WRK
                              
    class RTCConnection < Connection
      
      attr_reader :rtc, :project_area_id, :query_link, :factory_link
      
      def initialize(config=nil)
        super()
        read_config(config) if !config.nil?
      end
      
      def read_config(config)
        super(config)
        @url = XMLUtils.get_element_value(config, self.conn_class_name.to_s, "Url")
        @project_area = XMLUtils.get_element_value(config, self.conn_class_name.to_s, "ProjectArea")
        @id_field = XMLUtils.get_element_value(config, self.conn_class_name.to_s, "IDField", false) || "dc:identifier"
      end
      
      def name()
        return "RTC"
      end
      
      def version()
        return RallyEIF::RTC::Version
      end

      def self.version_message()
        version_info = "#{RallyEIF::RTC::Version}-#{RallyEIF::RTC::Version.detail}"
        return "RTCConnection version #{version_info}"
      end
      
      def get_backend_version()
        return "%s %s" % [name, version]
      end
      
      def field_exists? (field_name)
        # Is this a valid field name?

#        if !@lower_atts.member? field_name.to_s.downcase
#            RallyLogger.error(self, "RTC field '#{field_name.to_s}' is not a valid field name")
#            return false
#        end
        return true
      end
      
      def disconnect()
        # TODO
        RallyLogger.info(self,"Would disconnect at this point if we needed to")
      end
      
      def connect()
        
        RallyLogger.debug(self, "********************************************************")
        RallyLogger.debug(self, "Connecting to RTC:")
        RallyLogger.debug(self, "  Url               : #{@url}")
        RallyLogger.debug(self, "  Username          : #{@user}")
        RallyLogger.debug(self, "  Connector Name    : #{name}")
        RallyLogger.debug(self, "  Connector Version : #{version}")
        RallyLogger.debug(self, "  Artifact Type     : #{artifact_type}")
        RallyLogger.debug(self, "*******************************************************")   
          
        @rtc_http_client = HTTPClient.new
        @rtc_http_client.protocol_retry_count = 2
        @rtc_http_client.connect_timeout = 300
        @rtc_http_client.receive_timeout = 300
        @rtc_http_client.send_timeout    = 300
        @rtc_http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @rtc_http_client.transparent_gzip_decompression = true
        #@rtc_http_client.debug_dev = STDOUT
          
        #passed in proxy setup overrides env level proxy
        env_proxy = ENV["http_proxy"]   #todo - this will go in the future
        env_proxy = ENV["rtc_proxy"] if env_proxy.nil?
        if (!env_proxy.nil?) && (proxy_info.nil?)
          @rtc_http_client.proxy = env_proxy
        end
  
        @find_threads = 4

        auth_url = "https://#{@url}/jts/authenticated/j_security_check"
        #auth_url = "https://#{@url}/jts/authenticated/identity"
        
        RallyLogger.debug(self,"Auth URL: #{auth_url}")
        begin
          @cookie = send_login_request(auth_url, { :method => :get }, {'j_username'=>@user,'j_password'=>@password})

          RallyLogger.debug(self, "After authentication")
        rescue Exception => ex
          raise UnrecoverableException.new("Could not authenticate with username '#{@user}'.  \n RTC returned:#{ex.message}", self)
        end
        
        @rtc = @rtc_http_client
        
        return @rtc
      end
  
      def validate_project_area
        valid_project_area = false
        RallyLogger.info(self,"Validating existence of Project Area [#{@project_area}]")
        #project_url = "https://#{@url}/ccm/rootservices"
        #project_url = "https://#{@url}/ccm/process/project-areas"
        project_url = "https://#{@url}/ccm/oslc/workitems/catalog"
        args = { :method => :get }
        begin
          result = send_request(project_url, args)
        rescue Exception => ex
          raise UnrecoverableException.new("Could not connect to check project area. RTC returned: #{ex.message}",self)
        end
        xml_doc = Nokogiri::XML(result)
        # clobber the namespace
        xml_doc.remove_namespaces!
        
        valid_projects = []
        xml_doc.xpath("//title").each do |project|
          valid_projects.push(project.text)
          if ( @project_area == project.text ) 
            valid_project_area = true
            parent = project.parent
            RallyLogger.debug(self,"Parent: #{parent}")
            services_list_link = parent.at_xpath('services').attribute('resource')
            RallyLogger.debug(self,"Services Link = #{services_list_link}")
            
            begin
              services = send_request(services_list_link, args)
            rescue Exception => ex
              raise UnrecoverableException.new("Could not connect to get RTC services. RTC returned: #{ex.message}",self)
            end
            RallyLogger.debug(self,"Services List: #{services}")
            services_xml = Nokogiri::XML(services)
            # there should be a factory for creating the artifact type items
            #search_query = "//oslc_cm:factory[lower-case(@calm:id) = '#{@artifact_type}']"
            # do attribute search without worrying about case
            factory_query = "//oslc_cm:factory[
                translate(
                  @calm:id, 
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 
                  'abcdefghijklmnopqrstuvwxyz'
                ) = '#{@artifact_type}'
              ]/oslc_cm:url
            "
            factory = services_xml.at_xpath(factory_query)
            if factory.nil?
              RallyLogger.error(self,"Cannot locate factory for <ArtifactType> [#{@artifact_type}]")
              RallyLogger.error(self,"RTC returned: #{services}")
              raise UnrecoverableException.new("Cannot find <ArtifactType> [#{@artifact_type}] when searching for factories. ",self)              
            end
            
            @factory_link = factory.text
            @query_link = services_xml.at_xpath('//oslc_cm:simpleQuery/oslc_cm:url').text
            
          end
        end
        
        if ( !valid_project_area )
          RallyLogger.error(self,"Cannot locate project area [#{@project_area}]")
          RallyLogger.info(self,"Valid project names are #{valid_projects.join(',')}")
          raise UnrecoverableException.new("Cannot find <ProjectArea> called #{@project_area}",self)
        end
        return valid_project_area
      end
      
      def validate
        status_project = validate_project_area
        
        status_of_all_fields = true  # Assume all fields passed
        
        if !field_exists?(@external_id_field)
          status_of_all_fields = false
          RallyLogger.error(self, "RTC <ExternalIDField> '#{@external_id_field}' does not exist")
        end

        if @id_field
          if !field_exists?(@id_field)
            status_of_all_fields = false
            RallyLogger.error(self, "RTC <IDField> '#{@id_field}' does not exist")
          end
        end

        if @external_end_user_id_field
          if !field_exists?(@external_end_user_id_field)
            status_of_all_fields = false
            RallyLogger.error(self, "RTC <ExternalEndUserIDField> '#{@external_end_user_id_field}' does not exist")
          end
        end
                
        return status_of_all_fields
      end
      
      # find_by_external_id is forced from inheritance
      def find_by_external_id(external_id)
        begin
         # query = "dc:modified>=12-01-2014T00:00:00"
          query = "dc:type=\"com.ibm.team.apt.workItemType.story\" and #{@external_id_field}=\"#{external_id}\""  #TODO can we get this from knowing we're doing a plan item?
          RallyLogger.debug(self, " Using query: #{query}")
          artifact_array = find_by_query(query)
        rescue Exception => ex
          raise UnrecoverableException.new("Failed search using query: #{query}.  \n RTC api returned:#{ex.message}", self)
          raise UnrecoverableException.copy(ex,self)
        end
             
        if artifact_array.length == 0
          raise RecoverableException.new("No artifacts returned on query: '#{query}'", self)
          return nil
        end
        if artifact_array.length > 1
          RallyLogger.warning(self, "More than one artifact returned on query: '#{query}'")
          raise RecoverableException.new("More than one artifact returned on query: '#{query}'", self)
        end
        return artifact_array.first
      end
      
      def find_by_query(query_string)
        begin
          results = send_request(@query_link, { :method => :get, :accept => "application/json" }, { :"oslc_cm.query"  => query_string } )
        rescue Exception => ex
          raise UnrecoverableException.new("Could not execute query. RTC returned: #{ex.message}",self)
        end
        
        RallyLogger.debug(self, "Query Result: #{results}")
        
        json_obj = json_obj = JSON.parse(results)
        RallyLogger.info(self, "Found: #{json_obj['oslc_cm:totalCount']} items")
        
        populated_items = []
        json_obj['oslc_cm:results'].each do |item|
          populated_items.push(item)
        end
        return populated_items
      end
      
      def find_new()
        RallyLogger.info(self, "Find New RTC #{@artifact_type}s")
        artifact_array = []
        begin
         # query = "dc:modified>=12-01-2014T00:00:00"
          query = "dc:type=\"com.ibm.team.apt.workItemType.story\" and #{@external_id_field}=\"\""  #TODO can we get this from knowing we're doing a plan item?
          RallyLogger.debug(self, " Using query: #{query}")
          artifact_array = find_by_query(query)
        rescue Exception => ex
          raise UnrecoverableException.new("Failed search using query: #{query}.  \n RTC api returned:#{ex.message}", self)
          raise UnrecoverableException.copy(ex,self)
        end
        
        RallyLogger.info(self, "Found #{artifact_array.length} new #{@artifact_type}s in #{name()}.")
        return artifact_array
      end
      
      def find_updates(reference_time)
        RallyLogger.info(self, "Find Updated SalesForce #{@artifact_type}s since '#{reference_time}' (class=#{reference_time.class})")
        artifact_array = []
        begin
          query = "SELECT Id,Subject FROM #{@artifact_type} #{get_SOQL_where_for_updates()}"
          RallyLogger.debug(self, " Using SOQL query: #{query}")
          artifact_array = find_by_query(query)
        rescue Exception => ex
          raise UnrecoverableException.new("Failed search using query: #{query}.  \n SalesForce api returned:#{ex.message}", self)
          raise UnrecoverableException.copy(ex,self)
        end
        
        RallyLogger.info(self, "Found #{artifact_array.length} updated #{@artifact_type}s in #{name()}.")

        return artifact_array
      end
      
      def get_object_link(artifact)
        # We want:  "<a href='https://<SalesForce server>/<Artifact ID>'>link</a>"
        linktext = artifact[@id_field] || 'link'
        it = "<a href='https://#{@url}/#{artifact['Id']}'>#{linktext}</a>"
        return it
      end
    
      def pre_create(int_work_item)
        return int_work_item
      end
    
      def create_internal(int_work_item)
        RallyLogger.debug(self,"Preparing to create one #{@artifact_type}")
        args = {
          :method=>:post, 
          :payload=>int_work_item
        }
        begin
          new_item = JSON.parse(send_request(@factory_link, args))
        rescue RuntimeError => ex
          RallyLogger.error(self, "Could not create item: #{new_item}")
          RallyLogger.error(self, "Received error: #{ex}")
          raise RecoverableException.copy(ex, self)
        end
        RallyLogger.debug(self, "After creation: #{new_item}")
        RallyLogger.debug(self,"Created #{@artifact_type} #{new_item[@id_field]}")
        return new_item
      end
      
      # This method will hide the actual call of how to get the id field's value
      def get_id_value(artifact)
        RallyLogger.debug(self,"#{artifact.attributes}")
        return artifact["Id"]
      end
    
      def update_internal(artifact, int_work_item)
        artifact.update_attributes int_work_item
        return artifact
      end
      
      def update_external_id_fields(artifact, external_id, end_user_id=nil, item_link=nil)

        RallyLogger.debug(self, "Updating RTC item <ExternalIDField> field (#{@external_id_field}) to '#{external_id}'")
        fields = {@external_id_field => external_id} # we should always have one

        # Rally gives us a full '<a href=' tag
        if !item_link.nil?
          url_only = item_link.gsub(/.* href=["'](.*?)['"].*$/, '\1')
          fields[@external_item_link_field] = url_only unless @external_item_link_field.nil?
          RallyLogger.debug(self, "Updating RTC item <CrosslinkUrlField> field (#{@external_item_link_field}) to '#{fields[@external_item_link_field]}'")
        end
        
        if !@external_end_user_id_field.nil?
          fields[@external_end_user_id_field] = end_user_id  
          RallyLogger.debug(self, "Updating SF item <ExternalEndUserIDField>> field (#{@external_end_user_id_field}) to '#{fields[@external_end_user_id_field]}'")
        end
        
        update_internal(artifact, fields)
      end
 
      def send_request(url, args, url_params = {})
        RallyLogger.debug(self,"Sending request to RTC URL: #{url}")
        method = args[:method]
        accept_type = args[:accept] || "text/xml"
        req_args = {}
        url_params = {} if url_params.nil?
        req_args[:query] = url_params if url_params.keys.length > 0
  
        if (args[:method] == :post) || (args[:method] == :put)
          text_json = args[:payload].to_json
          req_args[:body] = text_json
        end
        
        req_args[:header] = setup_request_headers(args[:method],accept_type)

        begin
          response = @rtc_http_client.request(method, url, req_args)
        rescue Exception => ex
          msg =  "RTC Connection: - rescued exception - #{ex.message} on request to #{url} with params #{url_params}"
          RallyLogger.warning(self, msg)
          raise StandardError, msg
        end
  
        #RallyLogger.debug(self,"RTC response was - #{response.inspect}")
        if response.status_code != 200 && response.status_code != 201
          msg = "RTC Connection - HTTP-#{response.status_code} on request - #{url}."
          msg << "\nResponse was: #{response.body}"
          msg << "\nHeaders were: #{response.headers}"
          RallyLogger.error(self, "#{msg}")
          raise StandardError, msg
        end
  
        #json_obj = JSON.parse(response.body)   #todo handle null post error
        return response.body
      end

      def send_login_request(url, args, url_params = {})
         method = args[:method]
         req_args = {}
         url_params = {} if url_params.nil?
         req_args[:query] = url_params if url_params.keys.length > 0
   
         req_args[:header] = setup_request_headers(args[:method])
         
         begin
           response = @rtc_http_client.request(method, url, req_args)
         rescue Exception => ex
           msg =  "RTC Connection: - rescued exception - #{ex.message} on request to #{url} with params #{url_params}"
           raise StandardError, msg
         end
   
         #RallyLogger.debug(self,"RTC response was - #{response.inspect}")
         if ! response.headers || ! response.headers['Location'] || response.headers['Location'] =~ /authfailed/
           msg = "RTC Connection - Authentication Failed on request - #{url}."
           msg << "\nResponse was: #{response.body}"
           msg << "\nHeaders were: #{response.headers}"
           raise StandardError, msg
         end
   
         response.headers['Set-Cookie']
       end
           
        def setup_request_headers(http_method, accept='text/xml')
          req_headers = { "Accept" => accept }

          if (http_method == :post) || (http_method == :put)
            req_headers["Content-Type"] = "application/json"
            req_headers["Accept"] = "application/json"
          end
          
          auth = 'Basic ' + Base64.encode64( "#{@user}:#{@password}" ).chomp
          req_headers['Authorization'] = auth
             
          req_headers
        end
    
        def set_client_user(base_url, user, password)
          @rtc_http_client.set_auth(base_url, user, password)
          @rtc_http_client.www_auth.basic_auth.challenge(base_url)  #force httpclient to put basic on first req to rally
        end

    end
  end
end
