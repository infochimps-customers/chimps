require 'chimps/commands/base'
require 'chimps/commands/uses_model'

module Chimps
  module Commands
    class List < Chimps::Command

      BANNER = "chimps list [OPTIONS]"
      HELP   = <<EOF

List resources of a given type (defaults to dataset).

Lists your resources by default but see options below.

EOF

      MODELS = %w[dataset license]
      include Chimps::Commands::UsesModel

      def define_options
        on_tail("-a", "--all", "List all resources, not just those owned by you.") do |a|
          @all = a
        end

        on_tail("-s", "--[no-]skip-column-names", "Don't print column names in output.") do |s|
          @skip_column_names = s
        end
        
      end

      def all?
        @all
      end

      def params
        return { :id => Chimps.username } unless all?
      end

      def execute!
        Request.new(models_path, :params => params).get.print(:skip_column_names => @skip_column_names)
      end

    end
  end
end

