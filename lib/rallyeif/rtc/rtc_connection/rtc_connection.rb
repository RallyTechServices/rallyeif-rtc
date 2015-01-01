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
      
      attr_reader :rtc
      
      def initialize(config=nil)
        super()
        read_config(config) if !config.nil?
      end
      
      def read_config(config)
        super(config)
        @url = XMLUtils.get_element_value(config, self.conn_class_name.to_s, "Url")
        @project_area = XMLUtils.get_element_value(config, self.conn_class_name.to_s, "ProjectArea")
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

        if !@lower_atts.member? field_name.to_s.downcase
            RallyLogger.error(self, "RTC field '#{field_name.to_s}' is not a valid field name")
            return false
        end
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
        #url = "https://#{@url}/ccm/rootservices"
        url = "https://#{@url}/ccm/process/project-areas"
        args = { :method => :get }
        begin
          result = send_request(url, args)
        rescue Exception => ex
          raise UnrecoverableException.new("Could not connect to check project area. RTC returned: #{ex.message}",self)
        end
        #RallyLogger.debug(self, result)
        xml_doc = Nokogiri::XML(result)
        # clobber the namespace
        xml_doc.remove_namespaces!
        
        valid_projects = []
        xml_doc.xpath("//project-area").each do |project|
          valid_projects.push(project['name'])
          if ( @project_area == project['name'] ) 
            valid_project_area = true
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
        #return {@external_id_field.to_s=>external_id}
        #return @artifact_class.find(external_id)
        begin
          query = "SELECT Id,Subject FROM #{@artifact_type} WHERE #{@external_id_field} = '#{external_id}'"
          RallyLogger.debug(self, " Using SOQL query: #{query}")
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
      
      def find_by_query(string)
        unpopulated_items = @salesforce.query(string)
        populated_items = []
        unpopulated_items.each do |item|
          populated_items.push(@artifact_class.find(item['Id']))
        end
        return populated_items
      end
      
      def find_new()
        RallyLogger.info(self, "Find New SalesForce #{@artifact_type}s")
        artifact_array = []
        begin
          query = "SELECT Id FROM #{@artifact_type} #{get_SOQL_where_for_new()}"
          RallyLogger.debug(self, " Using SOQL query: #{query}")
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
        RallyLogger.debug(self,"Preparing to create one #{@artifact_class}")
        begin
          new_item = @artifact_class.new(int_work_item)
          temp = new_item.save
          new_item = @artifact_class.find(temp)  #otherwise we don't get the Name/ID
        rescue RuntimeError => ex
          raise RecoverableException.copy(ex, self)
        end
        RallyLogger.debug(self,"Created #{@artifact_class} #{new_item['Id']}")
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
      
      def update_external_id_fields(artifact, external_id, end_user_id, item_link)

        RallyLogger.debug(self, "Updating SF item <ExternalIDField> field (#{@external_id_field}) to '#{external_id}'")
        fields = {@external_id_field => external_id} # we should always have one

        # Rally gives us a full '<a href=' tag
        if !item_link.nil?
          url_only = item_link.gsub(/.* href=["'](.*?)['"].*$/, '\1')
          fields[@external_item_link_field] = url_only unless @external_item_link_field.nil?
        end
        RallyLogger.debug(self, "Updating SF item <CrosslinkUrlField> field (#{@external_item_link_field}) to '#{fields[@external_item_link_field]}'")
        
        fields[@external_end_user_id_field] = end_user_id unless @external_end_user_id_field.nil?
        RallyLogger.debug(self, "Updating SF item <ExternalEndUserIDField>> field (#{@external_end_user_id_field}) to '#{fields[@external_end_user_id_field]}'")
        
        update_internal(artifact, fields)
      end
 
      def send_request(url, args, url_params = {})
        RallyLogger.debug(self,"Sending request to RTC URL: #{url}")
        method = args[:method]
        req_args = {}
        url_params = {} if url_params.nil?
        req_args[:query] = url_params if url_params.keys.length > 0
  
#        if (args[:method] == :post) || (args[:method] == :put)
#          text_json = args[:payload].to_json
#          req_args[:body] = text_json
#        end
        req_args[:header] = setup_request_headers(args[:method])
        
        begin
          response = @rtc_http_client.request(method, url, req_args)
        rescue Exception => ex
          msg =  "RTC Connection: - rescued exception - #{ex.message} on request to #{url} with params #{url_params}"
          raise StandardError, msg
        end
  
        #RallyLogger.debug(self,"RTC response was - #{response.inspect}")
        if response.status_code != 200
          msg = "RTC Connection - HTTP-#{response.status_code} on request - #{url}."
          msg << "\nResponse was: #{response.body}"
          msg << "\nHeaders were: #{response.headers}"
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
           
        def setup_request_headers(http_method)
          req_headers = {}
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
