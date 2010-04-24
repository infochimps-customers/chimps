require 'ics/commands/base'
require 'ics/request'

module ICS
  module Commands
    class Test < ICS::Command

      BANNER = "usage: ics test"
      HELP = <<EOF

Print diagnostic information on the API credentials being used by ics
and send a test request to Infochimps to make sure the API credentials
work.

EOF
      def path
        "api_accounts/#{ICS::CONFIG[:api_key]}"
      end
      
      def execute!
        puts "Reading identity file at #{CONFIG[:identity_file]}" if ICS.verbose?
        ICS::Request.new(path, :sign => true).get.print
      end

    end
  end
end

