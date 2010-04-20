require 'ics/commands/base'
require 'ics/commands/uses_model'
require 'ics/request'

module ICS
  module Commands

    class Show < ICS::Command

      BANNER = "usage: ics show [OPTIONS] ID_OR_HANDLE"
      HELP   = <<EOF

Return a description of the resource (defaults to dataset) with the
given ID or HANDLE
EOF

      # Models this command applies to (default first)
      MODELS = %w[dataset collection source license tag category]
      include ICS::Commands::UsesModel

      def execute!
        ICS::Request.new(model_path).get.print
      end

    end
  end
end

