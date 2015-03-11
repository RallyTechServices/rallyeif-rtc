# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

#require 'yeti/field_handlers/rally_field_handler'

# Tag Name
#   RallyTruncateStringFieldHandler

# Description
#   Truncate field to maximum Rally field size.

# A RallyTruncate Field Handler is setup like:
#   <RallyTruncateStringFieldHandler>
#     <FieldName>name-of-field</FieldName>
#   </RallyTruncateStringFieldHandler>"

module RallyEIF
  module WRK
    module FieldHandlers

      class RallyTruncateStringFieldHandler < RallyFieldHandler

        attr_accessor :size
        
        def initialize(field_name = nil)
          super(field_name)
        end

        # Truncate intermediate work item value to RALLY_MAX_LENGTH chars
        def transform_in(value)
          new_value = value
          if value.to_s.length > @size
            new_value = value.to_s[0..(@size-1)]
            RallyLogger.warning(self, "Truncated value for #{@field_name}")
          end
          return new_value
        end

        def transform_out(artifact)
          # We never want a truncated description to go back to the other system
          @connection.get_value(artifact, @field_name.to_s)
        end

        def read_config(fh_element)
          fh_element.elements.each do |element|
            @size = 32768 
            if (element.name == "FieldName")
              @field_name = element.text.intern
            elsif ( element.name == "Size")
              @size = element.text.to_i
              if @size.nil? || @size < 1
                RallyLogger.error(self, "Size must be a positive number")
                @size = 32768
              end
            else
              RallyLogger.warning(self, "Element #{element.text} not expected")
            end
          end
          if (@field_name == nil)
            RallyLogger.error(self, "FieldName must not be null")
          end
        end

      end

    end
  end
end

