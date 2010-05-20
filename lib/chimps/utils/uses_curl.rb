module Chimps
  module Utils

    # A module which defines methods to interface with +curl+ via a
    # system call.
    module UsesCurl

      def curl
        `which curl`.chomp
      end

      # FIXME right now curl is the default but it really shouldn't be...
      # def define_curl_options
      #   on_tail("-c", "--curl", "Use curl instead of Ruby to upload package (faster)") do |c|
      #     @curl = c
      #   end
      # end

      # Should this use curl?
      # def curl?
      #   @curl
      # end
      
    end
  end
end
