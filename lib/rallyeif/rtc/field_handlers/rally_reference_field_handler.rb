# Copyright 2001-2014 Rally Software Development Corp. All Rights Reserved.

# <RallyReferenceFieldHandler>
#   <FieldName></FieldName>
#   <ReferencedFieldLookupID></ReferencedFieldLookupID>
# </RallyReferenceFieldHandler>

module RallyEIF
  module WRK
    module FieldHandlers

      #This Field Handler helps connect a single reference from one Rally object to another
      class RallyReferenceFieldHandler < RallyEIF::WRK::FieldHandlers::RallyFieldHandler

        attr_reader   :nameForRef
        attr_accessor :referenced_field_lookup_id

        VALID_REFERENCE_FIELDS = [:PortfolioItem, :Iteration, :Release, :Project, :TestCase, :TestCaseResult, :WorkProduct, :Requirement, :Parent, :TestFolder, :TestSet]

        def initialize(field_name = nil)
          super(field_name)
          @target_workspace = nil
          @nameForRef = {}
        end

        private
        def load_cache()
          @target_workspace = @connection.rally_api.find_workspace(@connection.workspace_name)
          @target_workspace.read()
        end

        public
        def derefForName(ref)
          return @nameForRef[ref] || ref
        end

        # TODO: if mapping iterations/releases and there are multiple projects,
        #       we could find the wrong iteration or project for the artifact

        # this "null" transform was being used in a rallyeif-wrk gem used for an AMEX beta build
        # that purportedly  handled project scoping when mapping Release/Iteration when multiple
        # projects were specified
#        def transform_in(value)
#          return value
#        end

        def transform_in(value)
          return nil if value.nil? || value.to_s.empty?
          value = value.to_s

          load_cache if @target_workspace.nil?

          #Work product does not match the Rally query object name so we override the value
          #We don't want users to have to understand this oddity
          #We can't do this in read_config since validate won't see artifact as a valid field
          queryable_type = @field_name
          queryable_type = :artifact if @field_name == :WorkProduct

          qualifying_refs = get_qualifiers(queryable_type, @referenced_field_lookup_id, value)

          if qualifying_refs.nil? or qualifying_refs.length == 0
            ref_string = nil
          else
            ref_string = qualifying_refs.first
            if qualifying_refs.length > 1
              RallyLogger.warning(self, "Found more than one Rally #{@field_name} with name #{@referenced_field_lookup_id} - #{value}")
            end
          end

          if ref_string == nil
            RallyLogger.warning(self,"Could not find Rally #{@field_name} with #{@referenced_field_lookup_id} - #{value}")
            # raise RecoverableException.new("Could not find Rally #{@field_name} with #{@referenced_field_lookup_id} - #{value}", self)
          end
          
          return ref_string
        end

        private
        def get_qualifiers(target_type, ref_field_lookup, value)
          query_fields = "ObjectID,FormattedID,Project,Name,%s" % ref_field_lookup
          query_string = '(%s = "%s")' % [ref_field_lookup, value]
          query = RallyAPI::RallyQuery.new(:type         => target_type.downcase.to_sym,
                                           :fetch        => query_fields,
                                           :query_string => query_string,
                                           :workspace    => @target_workspace
                                          )
          query_result = @connection.rally_api.find(query)
          return nil if query_result.nil? or query_result.results.length == 0

          if @field_name != :Project and @field_name != :WorkProduct
              # select only the query_result.results items whose Project name is one of the Projects in @connection.projects
              proj_names = @connection.project_names
              project_results = query_result.select { |qr| proj_names.include?(qr.Project.Name) }
              query_result = project_results
          end

          items = query_result  # predominant ref_field_lookup will be 'Name'
          if ref_field_lookup.to_s == 'FormattedID'
              stdized_value = value.upcase()
              items = query_result.select { |item| item.FormattedID.upcase == stdized_value }
          end

          refs = []
          items.each do |item|
            if !item.nil?
              if @field_name == :PortfolioItem 
                short_ref = "/PortfolioItem/%s/%s" % [item._ref.split('/')[-2], item.ObjectID]
              else 
                short_ref = "/%s/%s" % [item._ref.split('/')[-2], item.ObjectID]
              end
              refs << short_ref
              @nameForRef[short_ref] = item.Name
            end
          end

          return refs
        end

        public
        # Take a Rally reference and convert it to the name of the object
        # https://preview.rallydev.com/slm/webservice/1.15/iteration/763530 -> "Iteration 6 (R2)"
        def transform_out(rally_artifact)
          artifact_reference = @connection.get_value(rally_artifact, @field_name) # get the value from Rally
          value = nil
          if !artifact_reference.nil?
            artifact_reference.read
            value = @connection.get_value(artifact_reference, @referenced_field_lookup_id).to_s
          end
          return value
        end

        def read_config(fh_element)
          @referenced_field_lookup_id = "Name"  # use "Name" as the default field

          fh_element.elements.each do |element|
            if ( element.name == "FieldName" )
              @field_name = get_element_text(element).intern
            elsif ( element.name == "ReferencedFieldLookupID")
              @referenced_field_lookup_id = get_element_text(element).intern
            else
              problem = "Element #{element.name} not expected in RallyReferenceFieldHandler config"
              raise UnrecoverableException.new(problem, self)
            end
          end

          if ( VALID_REFERENCE_FIELDS.index(@field_name) == nil )
            problem = "Field name for RallyReferenceFieldHandler must be from the following set: #{VALID_REFERENCE_FIELDS}"
            raise UnrecoverableException.new(problem, self)
          end
        end

      end

    end
  end
end
