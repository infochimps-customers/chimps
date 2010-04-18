require 'json'
require 'restclient'

module ICS

  class Response < Hash

    attr_reader :rest_client_response

    def initialize rest_client_response
      @rest_client_response = rest_client_response
      super
      merge!(parse)
    end

    def blank?
      rest_client_response == 'null'
    end

    def parse
      return {} if blank?
      JSON.parse(rest_client_response)
    end

    def method_missing name, *args
      rest_client_response.send(name, *args)
    end
    
  end

  
end

