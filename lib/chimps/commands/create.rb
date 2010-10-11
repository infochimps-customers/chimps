module Chimps
  module Commands

    # A command to issue a POST requst to create a resource at
    # Infochimps.
    class Create < Chimps::Command

      USAGE = "usage: chimps create [OPTIONS] [PROP=VALUE] ..."
      HELP   = <<EOF

Create a single resource (defaults to a dataset) using the properties
and values supplied.

Properties and values can be supplied directly on the command line,
from an input YAML file, or multiple YAML documents streamed in via
STDIN, in order of decreasing precedence.
EOF

      include Chimps::Utils::UsesModel
      include Chimps::Utils::UsesYamlData

      # Issue the POST request.
      def execute!
        ensure_data_is_present!
        Request.new(models_path, :data => {model.to_sym => data } , :authenticate => true).post.print
      end
      
    end
  end
end

