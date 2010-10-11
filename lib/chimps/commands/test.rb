module Chimps
  module Commands

    # A command to test whether API authentication with Infochimps is
    # working.
    class Test < Chimps::Command

      USAGE = "usage: chimps test"
      HELP = <<EOF

Print diagnostic information on the API credentials being used by chimps
and send a test request to Infochimps to make sure the API credentials
work.

EOF

      # Path to submit test requests to.
      def path
        "api_accounts/#{Chimps::Config[:site][:key]}"
      end

      # Issue the request.
      def execute!
        response = Chimps::Request.new(path, :sign => true).get
        if response.error?
          case 
          when response.code == 404 then puts "ERROR Unrecognized API key" # record not found
          when response.code == 401 then puts "ERROR Signature does not match API key and query.  Is your secret key correct?" # unauthorized
          else
            nil                 # response gets printed anyway
          end
        end
        response.print
      end

    end
  end
end

