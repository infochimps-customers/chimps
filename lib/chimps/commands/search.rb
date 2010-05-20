module Chimps
  module Commands

    # A command to issue a GET request to create a search at
    # Infochimps.
    class Search < Chimps::Command

      # Default number of search results returned.
      # DEFAULT_LIMIT  = 20
      
      BANNER = "usage: chimps search [OPTIONS] QUERY"
      HELP   = <<EOF

Perform a search on Infochimps.  By default the search will be of
datasets and will return all matches for the given QUERY.
EOF
      
      # Path to search resource
      PATH   = 'search.json'
      
      # Models this command applies to (default first)
      MODELS = %w[dataset collection source license]
      include Chimps::Utils::UsesModel

      # FIXME have to implement this on the server side.
      # def limit
      #   @limit ||= DEFAULT_LIMIT
      # end

      def define_options
        # on_tail("-n", "--num-results NUM", "Return the given number of results instead of the default #{DEFAULT_LIMIT}") do |n|
        #   @limit = n.to_i
        # end

        on_tail("-s", "--[no-]skip-column-names", "don't print column names in output.") do |s|
          @skip_column_names = s
        end
        
      end

      def query
        raise CLIError.new("Must provide a query to search for") if argv.blank?
        argv.join(' ')
      end

      def params
        {
          :query => query,
          :model => model
        }
      end

      def execute!
        Chimps::Request.new(PATH, :params => params).get.print(:skip_column_names => @skip_column_names)
      end
    end
  end
end

