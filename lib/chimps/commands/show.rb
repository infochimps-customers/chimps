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
      include Chimps::Utils::UsesModel

      # The path of the URL to send a Request to.
      #
      # This is different from Chimps::Commands::UsesModel in that it
      # submits to the YAML path.
      def model_path
        "#{plural_model}/#{model_identifier}.yaml"
      end

      def execute!
        puts Chimps::Request.new(model_path).get.body
      end

    end
  end
end

