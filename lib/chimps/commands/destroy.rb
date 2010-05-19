require 'chimps/commands/base'
require 'chimps/request'
require 'chimps/commands/uses_model'

module Chimps
  module Commands
    class Destroy < Chimps::Command

      BANNER = "usage: chimps destroy [OPTIONS] ID_OR_HANDLE"
      HELP   = <<EOF

Destroys a resource of a given type (defaults to dataset) identified
by ID_OR_HANDLE.

EOF

      # Models this command applies to (default first)
      MODELS = %w[dataset package source license]
      include Chimps::Commands::UsesModel

      def execute!
        Request.new(model_path, :authenticate => true).delete.print
      end
      
    end
  end
end

