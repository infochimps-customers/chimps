module Chimps
  module Commands

    # A command to issue a GET request against an index of resources
    # at Infochimps.
    class List < Chimps::Command

      BANNER = "chimps list [OPTIONS]"
      HELP   = <<EOF

List resources of a given type (defaults to dataset).

Lists your resources by default but see options below.

EOF

      # Models that can be indexed (default first)
      MODELS = %w[dataset license source]
      include Chimps::Utils::UsesModel

      def define_options
        on_tail("-a", "--all", "List all resources, not just those owned by you.") do |a|
          @all = a
        end

        on_tail("-s", "--[no-]skip-column-names", "Don't print column names in output.") do |s|
          @skip_column_names = s
        end
        
      end

      # List all resources or just those owned by the Chimps user?
      def all?
        @all
      end

      # Parameters to include in the query.
      #
      # If listing all resources, then return +nil+.
      #
      # @return [Hash, nil]
      def params
        return { :id => Chimps.username } unless all?
      end

      # Issue the GET request.
      def execute!
        Request.new(models_path, :params => params).get.print(:skip_column_names => @skip_column_names)
      end

    end
  end
end

