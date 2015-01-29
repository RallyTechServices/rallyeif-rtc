# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

#require 'rallyeif-wrk'
#require 'rallyeif-rtc'

# A user field handler looks like this
#   <RTCTeamAreaFieldHandler>
#     <FieldName>rtc_cm:teamArea</FieldName>
#   </RTCTeamAreaFieldHandler>

module RallyEIF
  module WRK
    module FieldHandlers
      
    
      class RTCTeamAreaFieldHandler < RallyEIF::WRK::FieldHandlers::OtherFieldHandler
      
        def initialize(field_name = nil)
          super(field_name)
        end
        
        # from RTC, an artifact is just an ordinary hash
        def transform_out(artifact)
          other_value = @connection.get_value(artifact,@field_name)
          if other_value.nil? || other_value.empty?
            return nil
          end
          
          if other_value['rdf:resource'] 
            other_value = @connection.find_team_area_name(other_value['rdf:resource'] )
          end
          return other_value
        end
      
        def transform_in(value)
          raise RecoverableException.new("Transforming in for RTC Team Area is Not Implemented ", self)
        end
      end
    end
  end
end
