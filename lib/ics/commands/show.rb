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

      def path
        "#{plural_model}/#{model_identifier}.json"
      end

      def model_identifier
        raise CLIError.new("Must provide an ID or URL-escaped handle to show") if argv.first.blank?
        argv.first
      end

      def execute!
        ICS::Request.new(path).get.print
      end

    end
  end
end

