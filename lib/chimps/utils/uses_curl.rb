module Chimps
  module Utils

    # A module which defines methods to interface with +curl+ via a
    # system call.
    module UsesCurl

      def curl_program
        `which curl`.chomp
      end

      # Curl invocations (specifically those that do S3 HTTP POST) are
      # sometimes sensitive about the order of parameters.  Instead of
      # a Hash we therefore take an Array of pairs here.
      #
      # @param [Array<Array<String>>] array
      # @return [String]
      def curl_params params
        params.map do |param, value|
          "-F #{param}='#{value}'"
        end.join(' ')
      end
      
      def curl url, options={}
        options = {:method => "GET", :output => '/dev/null', :params => []}.merge(options)
        progress_meter = Chimps.verbose? ? '' : '-s -S'
        command = "#{curl_program} #{progress_meter} -X #{options[:method]} -o #{options[:output]}"
        command += " #{curl_params(options[:params])}" unless options[:params].empty?
        command += " '#{url}'"
        Chimps.log.info(command)
        system(command)
      end
            
    end
  end
end
