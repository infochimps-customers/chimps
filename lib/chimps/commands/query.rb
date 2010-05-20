module Chimps
  module Commands

    # A command to issue a GET request against the Infochimps paid
    # query API.
    class Query < Chimps::Command

      BANNER = "usage: chimps query [OPTIONS] DATASET [PROP=VALUE] ..."
      HELP   = <<EOF

Make a query of the given DATASET on the Infochimps paid query API
(not the main Infochimps site).

Properties and values can be supplied directly on the command line,
from an input YAML file, or multiple YAML documents streamed in via
STDIN, in order of decreasing precedence.

You can learn more about the Infochimps query API, discover datasets
to query, and look up the available parameters at

  http://api.infochimps.com

You can learn about the main Infochimps site API at

  http://infochimps.org/api
EOF

      include Chimps::Utils::UsesYamlData
      IGNORE_YAML_FILES_ON_COMMAND_LINE = true # must come after include

      # The dataset to query.
      #
      # @return [String]
      def dataset
        raise CLIError.new("Must provide a dataset to query.") if argv.first.blank?
        argv.first
      end

      # The path on the Infochimps query API to query.
      #
      # @return [String]
      def path
        dataset + ".json"
      end
      
      # Issue the GET request.
      def execute!
        response = QueryRequest.new(path, :query_params => data, :authenticate => true).get
        if response.error?
          response.print
        else
          puts response.inspect
        end
      end
      
    end
  end
end

