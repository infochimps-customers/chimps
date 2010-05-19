require 'chimps/commands/base'
require 'chimps/request'
require 'chimps/commands/uses_model'
require 'chimps/commands/uses_key_value_data'

module Chimps
  module Commands
    class Update < Chimps::Command

      BANNER = "usage: chimps update [OPTIONS] ID_OR_HANDLE [PROP=VALUE] ..."
      HELP   = <<EOF

Updates a single resource of a given type (defaults to dataset)
identified by ID_OR_HANDLE using the properties and values supplied.

Properties and values can be supplied directly on the command line,
from an input YAML file, or multiple YAML documents streamed in via
STDIN, in order of decreasing precedence.
EOF

      # Models this command applies to (default first)
      MODELS = %w[dataset source license]
      include Chimps::Commands::UsesModel
      include Chimps::Commands::UsesKeyValueData

      def execute!
        Request.new(model_path, :data => {model.to_sym => data } , :authenticate => true).put.print
      end
      
    end
  end
end

