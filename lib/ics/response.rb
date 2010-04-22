require 'json'
require 'restclient'
require 'ics/pretty_printers'

module ICS

  class Response < Hash
    include ICS::PrettyPrinters

    attr_reader :code, :headers, :body, :error_message

    def initialize rest_client_obj
      super      
      deal_with_rest_client_bullshit(rest_client_obj)
      parse_json!
    end

    def parse_json!
      unless body.blank? || body == 'null'
        begin        
          data = JSON.parse(body)
          # hack...sometimes we get back an array instead of a
          # hash...should change the API at ICS end
          case data            
          when Hash   then merge!(data)
          when Array  then self[:list]   = data # see corresponding pretty printers
          when String then self[:string] = data
          else
          end
        rescue JSON::ParserError => e
          puts body.inspect if ICS.verbose?
          $stdout.puts("WARNING: Unable to parse response from server")
        end
      end
    end

    def success?
      ! @rest_client_error
    end

    def error?
      ! success?
    end
    
    def print
      first_line = "#{code.to_s} -- "
      first_line += (success? ? "SUCCESS" : error_message)
      puts first_line if ICS.verbose? || error?
      puts pretty_print(self).join("\n")
    end

    protected
    # RestClient raises exceptions when things go wrong.  This isn't as useful 
    def deal_with_rest_client_bullshit rest_client_obj
      if rest_client_obj.is_a?(RestClient::Exception)
        @rest_client_response = rest_client_obj.response
        @rest_client_error    = rest_client_obj
      else
        @rest_client_response = rest_client_obj
        @rest_client_error    = nil
      end

      begin
        @body          = @rest_client_response.body
      rescue NoMethodError
        @body          = @rest_client_response.to_s
      end
      @code          = @rest_client_response.code
      @error_message = @rest_client_error.message unless success?
    end

  end
end
  
    
    
