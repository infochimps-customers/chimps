module Chimps
  module Commands

    # A command to issue a PUT request to update a resource at
    # Infochimps.
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
      include Chimps::Utils::UsesModel
      include Chimps::Utils::UsesKeyValueData

      # Issue the PUT request.
      def execute!
        ensure_data_is_present!
        Request.new(model_path, :data => {model.to_sym => data } , :authenticate => true).put.print
      end
      
    end
  end
end

