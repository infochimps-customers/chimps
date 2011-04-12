require 'yaml'
require 'json'
        
module Chimps

  # A class to wrap responses from the Infochimps API.
  class Response

    # The response body.
    attr_reader :body

    # The parsed data of the body
    attr_reader :data

    # The error message for this response, if it was an error.
    #
    # This is actually generated within RestClient from the HTTP
    # status code and attached to the response.  It is passed in when
    # initializing a Chimps::Response by a Chimps::Request.
    attr_reader :error
    
    # Return a Response from the +body+.
    #
    # If <tt>:error</tt> is passed then this response is is considered
    # an error with the given message.
    #
    # @param [String, #to_i, #headers] body
    # @param [Hash] options
    # @option options [String] error the error message
    # @return [Chimps::Response]
    def initialize body, options={}
      @body  = body
      @error = options[:error]
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
    #
    # @return [Chimps::Response]
    def parse!
      @data   = parse_response_body
      @parsed = true
      self
    end

    # Parse the response from Infochimps -- will do nothing if the
    # response has already been parsed.
    def parse
      return if @parsed
      parse!
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

    # Print this response.
    #
    # @param [Hash] options
    # @option options [true, false] pretty whether to pretty print the response
    def print options={}
      $stderr.puts(diagnostic_line) if error? || Chimps.verbose?
      output = (options[:to] || $stdout)
      if error?
        parse!
        output.puts data['errors']  if data['errors']
        output.puts data['message'] if data['message']
      else
        case
        when options[:yaml]
          parse!
          output.puts data.to_yaml
        when options[:json] && options[:pretty]
          parse!
          if options[:pretty]
            output.puts JSON.pretty_generate(data)
          else
            output.puts data.to_json
          end
        when headers[:content_type] =~ /json/i && options[:pretty]
          parse!
          output.puts JSON.pretty_generate(data)
        when headers[:content_type] =~ /tab/i && options[:pretty]
          Utils::Typewriter.new(self).print
        else
          output.puts body unless body.chomp.strip.size == 0
        end
      end
    end

    def print_headers options={}
      output = (options[:output]  || $stdout)
      self.body.raw_headers.each_pair do |name, value|
        output.puts "#{name}: #{value}"
      end
    end

    def method_missing name, *args, &block
      data.send(name, *args, &block)
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
    def parse_error! error
      if Chimps.verbose?
        puts "\n\n#{body}" 
      end
      nil
    end

    # Parse the body of this response using the YAML or JSON libraries
    # into a Ruby data structure.
    #
    # @return [Hash, Array, String]
    def parse_response_body
      return {} if body.blank? || body == 'null'
      if content_type == :yaml
        begin
          YAML.load(StringIO.new(body))
        rescue YAML::ParseError => e 
          parse_error! e
        rescue ArgumentError => e
          parse_error! e
        end
      else
        begin
          JSON.parse(body)
        rescue JSON::ParserError => e
          parse_error! e
        end
      end
    end
    
  end
end

