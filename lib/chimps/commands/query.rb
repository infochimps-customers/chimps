module Chimps
  module Commands

    # A command to issue a GET request against the Infochimps paid
    # query API.
    class Query < Chimps::Command

      USAGE = "usage: chimps query [OPTIONS] DATASET [PROP=VALUE] ..."
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
      def ignore_first_arg_on_command_line
        true
      end

      # The dataset to query.
      #
      # @return [String]
      def dataset
        raise CLIError.new("Must provide a dataset to query.") if config.argv.first.blank?
        config.argv.first
      end

      # The path on the Infochimps query API to query.
      #
      # @return [String]
      def path
        dataset + ".json"
      end

      # Should the query output be pretty-printed?
      #
      # @return [true, nil]
      def pretty_print?
        config[:pretty_print]
      end

      # The requests that will be sent to the server.
      #
      # @return [Array<Chimps::QueryRequest>]
      def requests
        ensure_data_is_present!
        if data.is_a?(Hash)
          [QueryRequest.new(path, :query_params => data, :authenticate => true)]
        else # it's an Array, see Chimps::Utils::UsesYamlData
          data.map { |params| QueryRequest.new(path, :query_params => params, :authenticate => true) }
        end
      end
      
      # Issue the GET request.
      def execute!
        requests.each do |request|
          response = request.get
          if response.error?
            response.print :to => $stderr
          else
            puts pretty_print? ? JSON.pretty_generate(response.data) : response.body
          end
        end
      end
      
    end
  end
end

