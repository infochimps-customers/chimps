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
        response = ICS::Request.new(path, :sign => true).get
        if response.error?
          case response.code
          when /404/ then puts "ERROR Unrecognized API key"
          when /401/ then puts "ERROR Signature does not match API key and query.  Is your secret key correct?"
          else
            nil                 # response gets printed anyway
          end
        end
        response.print
      end

    end
  end
end

