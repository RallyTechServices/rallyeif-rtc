# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

#require 'rallyeif-wrk'
#require 'rallyeif-rtc'

# A RTC Link field handler looks like this
#
#<RTCLinkFieldHandler>
#  <FieldName>rtc_cm:com.ibm.team.workitem.linktype.parentworkitem.parent</FieldName> <!-- the field on the story -->
#  <ReferencedFieldLookupID>rtc_cm:jirakey</ReferencedFieldLookupID>  <!-- the field on the thing that's at the other end of the reference pointer -->
#</RTCLinkFieldHandler>"

module RallyEIF
  module WRK
    module FieldHandlers
      
    
      class RTCLinkFieldHandler < RallyEIF::WRK::FieldHandlers::OtherFieldHandler
      
        def initialize(field_name = nil)
          super(field_name)
        end
        
        # from RTC, an artifact is just an ordinary hash
        def transform_out(artifact)
         
          other_value = @connection.get_value(artifact,@field_name)
          if other_value.nil? || other_value.empty?
            return nil
          end
                    
          if other_value.kind_of?(Array)
            other_value.each do |item|
              if item[@referenced_field_lookup_id] 
                return item[@referenced_field_lookup_id]
              end
            end
          elsif other_value[@referenced_field_lookup_id] 
            return other_value[@referenced_field_lookup_id]
          else
            return nil
          end
          
          return nil
        end
      
        def transform_in(value)
          raise RecoverableException.new("Transforming in for RTC Link Fields is Not Implemented ", self)
        end
        
        def read_config(fh_element)
          @referenced_field_lookup_id = "Name"  # use "Name" as the default field

          fh_element.elements.each do |element|
            if ( element.name == "FieldName" )
              @field_name = get_element_text(element).intern
            elsif ( element.name == "ReferencedFieldLookupID")
              @referenced_field_lookup_id = get_element_text(element)
            else
              problem = "Element #{element.name} not expected in RTCResourceFieldHandler config"
              raise UnrecoverableException.new(problem, self)
            end
          end

        end #end read_config
         
      end
    end
  end
end
