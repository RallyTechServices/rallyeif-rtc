# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

#require 'rallyeif-wrk'
#require 'rallyeif-rtc'

# A Resource field handler looks like this
#   <RTCResourceFieldHandler>
#     <FieldName>rtc_cm:teamArea</FieldName>
#     <ReferencedFieldLookupID>dc:title</ReferencedFieldLookupID>  <!-- the story on the thing that's at the other end of the reference pointer -->
#   </RTCResourceFieldHandler>

module RallyEIF
  module WRK
    module FieldHandlers
      
    
      class RTCResourceFieldHandler < RallyEIF::WRK::FieldHandlers::OtherFieldHandler
      
        def initialize(field_name = nil)
          super(field_name)
        end
        
        # from RTC, an artifact is just an ordinary hash
        def transform_out(artifact)
          other_value = @connection.get_value(artifact,@field_name)
          if other_value.nil? || other_value.empty?
            return nil
          end
                    
          if !other_value[@referenced_field_lookup_id].nil?
            string_value = other_value[@referenced_field_lookup_id]

            if ( @field_name.to_s == "rtc_cm:release" || @field_name.to_s == "rtc_cm:plannedFor" ) && 
              ( string_value == "Unassigned" || string_value == "Product Backlog" )
              return nil
            else
              return string_value
            end
          else
            return nil
          end
        end
      
        def transform_in(value)
          raise RecoverableException.new("Transforming in for RTC Resource Fields is Not Implemented ", self)
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
