# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

#require 'rallyeif-wrk'
#require 'rallyeif-rtc'

# A user field handler looks like this
#   <RTCComplexityFieldHandler>
#     <FieldName>rtc_cm:com.ibm.team.apt.attribute.complexity</FieldName>
#   </RTCComplexityFieldHandler

module RallyEIF
  module WRK
    module FieldHandlers
      
    
      class RTCComplexityFieldHandler < RallyEIF::WRK::FieldHandlers::OtherFieldHandler
      
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
            other_value = other_value['rdf:resource'].gsub(/.*\//,"").to_f
          end
          return other_value
        end
      
        def transform_in(value)
          raise RecoverableException.new("Transforming in for RTC Complexity is Not Implemented ", self)
        end
      end
    end
  end
end
