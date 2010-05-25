module Chimps

  # A class to wrap responses from the Infochimps API.
  class Response < Hash

    # The response body.
    attr_reader :body

    # The error message for this response, if it was an error.
    #
    # This is actually generated within RestClient from the HTTP
    # status code and attached to the response.  It is passed in when
    # initializing a Chimps::Response by a Chimps::Request.
    attr_reader :error
    
    # Return a response built from a String with the
    # RestClient::Response module mixed-in.
    #
    # If <tt>:error</tt> is passed then this response is is considered
    # an error with the given message.
    #
    # @param [String, #to_i, #headers] body
    # @param [Hash] options
    # @option options [String] error the error message
    # @return [Chimps::Response]
    def initialize body, options={}
      super()
      @body  = body
      @error = options[:error]
      parse!
    end

    # The HTTP status code of the response.
    #
    # @return [Integer]
    def code
      @code ||= body.to_i
    end

    # The HTTP headers of the response.
    #
    # @return [Hash]
    def headers
      @headers ||= body.headers
    end

    # The <tt>Content-type</tt> of the response.
    #
    # Will return <tt>:yaml</tt> or <tt>:json</tt> if possible, else
    # just the raw <tt>Content-type</tt>.
    #
    # @return [Symbol, String]
    def content_type
      @content_type ||= case headers[:content_type]
                        when /json/ then :json
                        when /yaml/ then :yaml
                        else headers[:content_type]
                        end
    end
    
    # Parse the response from Infochimps.
    def parse!
      data = parse_response_body
      case data
        # hack...sometimes we get back an array instead of a
        # hash...should change the API at Chimps end
      when Hash   then merge!(data)
      when Array  then self[:array]  = data # see Chimps::Typewriter#accumulate
      when String then self[:string] = data
      end
    end

    # Was this response a success?
    #
    # @return [true, false]
    def success?
      ! error?
    end

    # Was this response an error??
    #
    # @return [true, false]
    def error?
      !! @error
    end

    # Return a new Hash consisting of the data from this response.
    #
    # FIXME This is used when pretty printing -- though it shouldn't
    # be necessary.
    #
    # @return [Hash]
    def data
      returning({}) do |d|
        each_pair do |key, value|
          d[key] = value
        end
      end
    end

    # Print this response.
    #
    # Options are also passed to Chimps::Typewriter.new; consult for
    # details.
    #
    # @param [Hash] options
    # @option options
    def print options={}
      out = options[:to] || options[:out] || $stdout
      err =                 options[:err] || $stderr
      err.puts(diagnostic_line) if error? || Chimps.verbose?
      Typewriter.new(self, options).print(out)
    end

    protected

    # Construct and return a line of diagnostic information on this
    # response.
    #
    # @return [String]
    def diagnostic_line
      line = "#{code.to_s} -- "
      line += (success? ? "SUCCESS" : error)
      line
    end

    # Raise a Chimps::ParseError, optionally including the response
    # body in the error message if Chimps is verbose.
    def parse_error!
      message = Chimps.verbose? ? "#{diagnostic_line}\n\n#{body}" : diagnostic_line
      raise ParseError.new(message)
    end

    # Parse the body of this response using the YAML or JSON libraries
    # into a Ruby data structure.
    #
    # @return [Hash, Array, String]
    def parse_response_body
      return {} if body.blank? || body == 'null'
      if content_type == :yaml
        require 'yaml'
        begin
          YAML.parse(body)
        rescue YAML::ParseError => e 
          parse_error!
        rescue ArgumentError => e # WHY does YAML return an ArgumentError on malformed input...?
          @error = "Response was received but was malformed"
          parse_error!
        end
      else
        require 'json'
        begin
          JSON.parse(body)
        rescue JSON::ParserError => e
          parse_error!
        end
      end
    end
    
  end
end

