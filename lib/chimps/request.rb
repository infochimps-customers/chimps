require 'restclient'

require 'chimps/response'
require 'chimps/utils'

module Chimps

  # A class to encapsulate requests made of Infochimps.
  #
  # Essentialy a wrapper for RestClient::Resource with added
  # funcionality for automatically signing requests and parsing
  # Infochimps API responses.
  class Request < RestClient::Resource

    # Default headers to pass with every request.
    DEFAULT_HEADERS = { :content_type => 'application/json', :accept => 'application/json' }

    # Path of the URL to submit to.  Must be a String.
    attr_accessor :path

    # Parameters to include in the query string of the URL to submit
    # to.  Must be a Hash.
    attr_accessor :query_params

    # Data to include in the body of the request.  Must be a Hash.
    attr_accessor :data

    # Initialize a Request to the given +path+.
    #
    # Query parameters and data can be passed in as hashes named
    # <tt>:params</tt> and <tt>:data</tt>, respectively.
    #
    # If <tt>:sign</tt> is passed in the +options+ then the URL of
    # this request will be signed with the Chimps user's Infochimps
    # API key and secret.  Failure to properly sign will raise an
    # error.
    #
    # If <tt>:sign_if_possible</tt> is passed in the +options+ then an
    # attemp to sign the URL will be made though an error will _not_
    # raise an error.
    #
    # @param [String] path
    # @param [Hash] options
    # @option options [Hash] params Query parameters to include in the URL
    # @option options [Hash] data Data to include in the request body
    # @option options [true, false] sign Sign this request, raising an error on failure
    # @option options [true, false] sign_if_possible Sign this request, no error on failure
    # @return [Chimps::Request]
    def initialize path, options={}
      @path         = path
      @query_params = options[:query_params] || options[:params] || {}
      @data         = options[:data]         || {}
      @authentication_required      = [:authenticate, :authenticated, :authenticate_if_possible, :sign, :signed, :sign_if_possible].any? { |key| options.include?(key) }
      @forgive_authentication_error = options[:sign_if_possible] || options[:authenticate_if_possible]
      authenticate_if_necessary!
      super url_with_query_string
    end

    # Should the request be authenticated?
    #
    # @return [true, false]
    def authenticate?
      @authentication_required
    end
    alias_method :sign?, :authenticate?

    # Is this request authentiable (has the Chimps user specified an
    # API key and secret in their configuration file)?
    #
    # @return [true, false]
    def authenticable?
      !Chimps::CONFIG[:api_key].blank? && !Chimps::CONFIG[:api_secret].blank?
    end
    alias_method :signable?, :authenticable?

    # Return the URL for this request with the (signed, if necessary)
    # query string appended.
    #
    # @return [String]
    def url_with_query_string
      base_url = File.join(Chimps::CONFIG[:host], path)
      base_url += "?#{query_string}" unless query_string.blank?
      base_url
    end

    # Return the query string for this request, signed if necessary.
    #
    # @return [String]
    def query_string
      (authenticate? && authenticable?) ? signed_query_string : unsigned_query_string
    end

    # Perform a GET request to this URL, returning a parsed response.
    #
    # Any headers in +options+ will passed to
    # RestClient::Resource.get.
    #
    # @param [Hash] options
    # @return [Chimps::Response]
    def get options={}
      handle_exceptions do
        puts "GET #{url}" if Chimps.verbose?
        Response.new(super(DEFAULT_HEADERS.merge(options)))
      end
    end

    # Perform a POST request to this URL, returning a parsed response.
    #
    # Any headers in +options+ will passed to
    # RestClient::Resource.post.
    #
    # @param [Hash] options
    # @return [Chimps::Response]
    def post options={}
      handle_exceptions do
        puts "POST #{url}" if Chimps.verbose?
        Response.new(super(data_text, DEFAULT_HEADERS.merge(options)))
      end
    end

    # Perform a PUT request to this URL, returning a parsed response.
    #
    # Any headers in +options+ will passed to
    # RestClient::Resource.put.
    #
    # @param [Hash] options
    # @return [Chimps::Response]
    def put options={}
      handle_exceptions do
        puts "PUT #{url}" if Chimps.verbose?
        Response.new(super(data_text, DEFAULT_HEADERS.merge(options)))
      end
    end

    # Perform a DELETE request to this URL, returning a parsed
    # response.
    #
    # Any headers in +options+ will passed to
    # RestClient::Resource.delete.
    #
    # @param [Hash] options
    # @return [Chimps::Response]
    def delete options={}
      handle_exceptions do
        puts "DELETE #{url}" if Chimps.verbose?
        Response.new(super(DEFAULT_HEADERS.merge(options)))
      end
    end
    
    protected
    # Yield to +block+ but rescue any RestClient errors by wrapping
    # them in a Chimps::Response.
    def handle_exceptions &block
      begin
        yield
      rescue RestClient::Exception => e
        return Response.new(e.response, :error => e.message)
      end
    end

    # Authenticate this request by stuffing the <tt>:requested_at</tt>
    # and <tt>:api_key</tt> properties into its <tt>:query_params</tt>
    # hash.
    #
    # Will do nothing at all if Chimps::Request#authenticate? returns
    # false.
    def authenticate_if_necessary!
      return unless authenticate?
      raise Chimps::AuthenticationError.new("API key or secret missing from #{CONFIG[:identity_file]}") unless (authenticable? || @forgive_authentication_error)
      query_params[:requested_at] = Time.now.to_i.to_s
      query_params[:api_key]      = Chimps::CONFIG[:api_key]
    end

    # Return the sorted keys of the query params.
    #
    # @return [Array]
    def alphabetical_params
      query_params.keys.map(&:to_s).sort
    end

    # Return an unsigned query string for this request.
    #
    # Query parameters will be used in alphabetical order.
    #
    # @return [String]
    def unsigned_query_string
      require 'cgi'
      alphabetical_params.map { |key| "#{CGI::escape(key.to_s)}=#{CGI::escape(query_params[key.to_sym].to_s)}" }.join("&")
    end

    # Return an unsigned query string for this request without the
    # <tt>&</tt> and <tt>=</tt> characters.
    #
    # This is the text that will be signed for GET and DELETE
    # requests.
    #
    # @return [String]
    def unsigned_query_string_stripped
      require 'cgi'      
      @query_params_text ||= alphabetical_params.map { |key| CGI::escape(key.to_s) + CGI::escape(query_params[key.to_sym].to_s) }.join('')
    end

    # Return the data of this request as a string.
    #
    # This is the text that will be signed for POST and PUT requests.
    #
    # @return [String]
    def data_text
      @data_text ||= data.to_json
    end

    # Sign +string+ by concatenting it with the secret and computing
    # the MD5 digest of the whole thing.
    #
    # @param [String]
    # @return [String]
    def sign string
      raise Chimps::AuthenticationError.new("No API secret stored in #{CONFIG[:identity_file]}.") unless (authenticable? || @forgive_authentication_error)
      require 'digest/md5'
      Digest::MD5.hexdigest(string + CONFIG[:api_secret])
    end

    # Append the signature to the unsigned query string.
    #
    # The signature made from the Chimps user's API secret and either
    # the query string text (stripped of <tt>&</tt> and <tt>=</tt>)
    # for GET and DELETE requests or the request body for POST and PUT
    # requests.
    #
    # @return [String]
    def signed_query_string
      signature = sign(data.blank? ? unsigned_query_string_stripped : data_text)
      "#{unsigned_query_string}&signature=#{signature}"
    end

  end
end

