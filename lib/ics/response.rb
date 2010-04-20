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
      merge!(JSON.parse(body)) unless body.blank? || body == 'null'
    end

    def success?
      ! @rest_client_error
    end

    def print
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

      @code          = @rest_client_response.code
      @body          = @rest_client_response.to_s
      @error_message = @rest_client_error.message unless success?
    end

    def emit_first_line
      first_line = "#{code.to_s} -- "
      first_line += (success? ? "SUCCESS" : error_message)
      puts first_line
    end
  end
end
  
    
    
