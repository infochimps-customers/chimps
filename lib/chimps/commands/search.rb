module Chimps
  module Commands

    # A command to issue a GET request to create a search at
    # Infochimps.
    class Search < Chimps::Command

      # Describes usage of search command.
      USAGE = "usage: chimps search [OPTIONS] QUERY"

      # Default number of search results returned.
      # DEFAULT_LIMIT  = 20
      
      HELP   = <<EOF

Perform a search on Infochimps.  By default the search will be of
datasets and will return all matches for the given QUERY.
EOF
      
      # Path to search resource
      PATH   = 'search.json'
      
      include Chimps::Utils::UsesModel

      # FIXME have to implement this on the server side.
      # def limit
      #   @limit ||= DEFAULT_LIMIT
      # end

      def query
        raise CLIError.new("Must provide a query to search for") if config.argv.blank?
        config.argv.join(' ')
      end

      def params
        {
          :query => query,
          :model => model
        }
      end

      def execute!
        Chimps::Request.new(PATH, :params => params).get.print(:skip_column_names => config[:skip_column_names])
      end
    end
  end
end

