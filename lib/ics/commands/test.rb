require 'ics/commands/base'
require 'ics/request'

module ICS
  module Commands
    class Test < ICS::Command

      PATH = 'test_api_authentication.json'

      BANNER = "usage: ics test"
      HELP = <<EOF

Print diagnostic information on the API credentials being used by ics
and send a test request to Infochimps to make sure the API credentials
work.

EOF
      def define_options
        on("-i", "--identity-file [PATH]", "Use the given YAML identify file to authenticate with Infochimps instead of the default (~/.ics) ") do |i|
          ICS::CONFIG[:identify_file] = File.expand_path(i)
        end
      end

      def execute!
        emit("Reading identity file at #{CONFIG[:identity_file]}")
        emit(parse_json(ICS::Request.new(PATH, :sign => true).get))
      end

      def parse_json json
        api_account = json['account']['api_account']
        "SUCCESS: Using API key #{api_account['api_key']} belonging to Infochimps user #{api_account['owner']['username']} created on #{api_account['created_at']}"
      end
      

    end
  end
end

