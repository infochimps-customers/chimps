require 'chimps/commands/base'
require 'chimps/request'
require 'chimps/commands/uses_model'
require 'chimps/commands/uses_key_value_data'

module Chimps
  module Commands
    class Create < Chimps::Command

      BANNER = "usage: chimps create [OPTIONS] [PROP=VALUE] ..."
      HELP   = <<EOF

Create a single resource (defaults to dataset) using the properties
and values supplied.

Properties and values can be supplied directly on the command line,
from an input YAML file, or multiple YAML documents streamed in via
STDIN, in order of decreasing precedence.
EOF

      # Models this command applies to (default first)
      MODELS = %w[dataset source license]
      include Chimps::Commands::UsesModel
      include Chimps::Commands::UsesKeyValueData

      def path
        model + 's.json'
      end

      def execute!
        Request.new(path, :data => {model.to_sym => data } , :authenticate => true).post.print
      end
      
    end
  end
end

