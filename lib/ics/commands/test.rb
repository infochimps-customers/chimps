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
      def execute!
        puts "Reading identity file at #{CONFIG[:identity_file]}" if ICS.verbose?
        ICS::Request.new(PATH, :sign => true).get.print
      end

    end
  end
end

