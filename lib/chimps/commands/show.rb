require 'chimps/commands/base'
require 'chimps/commands/uses_model'
require 'chimps/request'

module Chimps
  module Commands

    class Show < Chimps::Command

      BANNER = "usage: chimps show [OPTIONS] ID_OR_HANDLE"
      HELP   = <<EOF

Return a description of the resource (defaults to dataset) with the
given ID or HANDLE
EOF

      # Models this command applies to (default first)
      MODELS = %w[dataset collection source license tag category]
      include Chimps::Commands::UsesModel

      def execute!
        Chimps::Request.new(model_path).get.print
      end

    end
  end
end

