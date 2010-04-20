require 'ics/commands/base'
require 'ics/request'
require 'ics/commands/uses_model'

module ICS
  module Commands
    class Destroy < ICS::Command

      BANNER = "usage: ics destroy [OPTIONS] ID_OR_HANDLE"
      HELP   = <<EOF

Destroys a resource of a given type (defaults to dataset) identified
by ID_OR_HANDLE.

EOF

      # Models this command applies to (default first)
      MODELS = %w[dataset source license]
      include ICS::Commands::UsesModel

      def execute!
        Request.new(model_path, :authenticate => true).delete.print
      end
      
    end
  end
end

