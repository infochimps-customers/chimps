module Chimps
  module Commands

    # A command to issue a GET request against an index of resources
    # at Infochimps.
    class List < Chimps::Command

      USAGE = "usage: chimps list [OPTIONS]"
      HELP   = <<EOF

List resources of a given type (defaults to dataset).

Lists your resources by default but see options below.

EOF

      include Chimps::Utils::UsesModel

      # List all resources or just those owned by the Chimps user?
      def all?
        config[:all]
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
        Request.new(models_path, :params => params).get.print(:skip_column_names => config[:skip_column_names])
      end

    end
  end
end

