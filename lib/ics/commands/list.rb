require 'ics/commands/base'
require 'ics/commands/uses_model'

module ICS
  module Commands
    class List < ICS::Command

      BANNER = "ics list [OPTIONS]"
      HELP   = <<EOF

List resources of a given type (defaults to dataset).

Lists your resources by default but see options below.

EOF

      MODELS = %w[dataset license]
      include ICS::Commands::UsesModel

      def define_options
        on_tail("-a", "--all", "List all resources, not just those owned by you.") do |a|
          @all = a
        end
      end

      def all?
        @all
      end

      def params
        return { :id => ICS.username } unless all?
      end

      def execute!
        Request.new(models_path, :params => params).get.print
      end

    end
  end
end

