require 'ics/commands/base'
require 'ics/request'

module ICS
  module Commands
    class Search < ICS::Command

      LIMIT  = 20
      MODELS = %w[dataset collection source license field]
      MODELS_STRING = "dataset (default), collection, source, license, or field"
      PATH   = 'search.json'
      
      BANNER = "usage: ics search [OPTIONS] QUERY"
      HELP   = <<EOF

Perform a search on Infochimps.  By default the search will be of
datasets and will return #{LIMIT} datasets that match the given QUERY.

Options include
EOF


      attr_reader :model, :limit

      def initialize argv
        @model = 'dataset'
        @n     = LIMIT
        super argv
      end

      def define_options
        on("-m", "--model MODEL", "Search a different resource, one of: #{MODELS_STRING}") do |m|
          model = m
        end

        on("-n", "--num-results NUM", "Return the given number of results instead of the default #{LIMIT}") do |n|
          @limit = n.to_i
        end
        
      end

      def query
        raise CLI::Error.new("Must provide a query to search for") if argv.blank?
        argv.join(' ')
      end

      def params
        {
          :query => query,
          :model => model,
          :limit => limit
        }
      end

      def execute!
        emit(*extract_model_summaries(ICS::Request.new(PATH, :params => params).get))
      end

      def extract_model_summaries json
        returning([]) do |lines|
          json['search']['results'].each do |result|
            obj = result[model]
            lines << [obj['id'], obj['protected'], obj['price-in-cents'], obj['protected'], obj['title']]
          end
        end
      end

      def model= model
        raise CLI::Error.new("Invalid model: #{model}.  Must be one of #{MODELS_STRING}") unless MODELS.include?(model)
        @model = model
      end
      
    end
  end
end

