require 'restclient'

module Chimps

  # A class to encapsulate requests made of Infochimps.
  #
  # Essentialy a wrapper for RestClient::Resource with added
  # funcionality for automatically signing requests and parsing
  # Infochimps API responses.
  class Request < RestClient::Resource

    # Default headers to pass with every request.
    DEFAULT_HEADERS = { :content_type => 'application/json', :accept => 'application/json', :user_agent => "Chimps #{Chimps.version}" }

    # Path of the URL to submit to.  Must be a String.  Can start with
    # an initial '/' or not -- no big deal ;)
    attr_accessor :path

    # Parameters to include in the query string of the URL to submit
    # to.  Can be a string or a Hash
    attr_accessor :query_params

    # Data to include in the body of the request.  Can be a Hash or a
    # String.
    attr_accessor :body

    # Initialize a Request to the given +path+.
    #
    # Query parameters and data can be passed in as hashes named
    # <tt>:params</tt> and <tt>:body</tt>, respectively.
    #
    # If <tt>:sign</tt> is passed in the +options+ then the URL of
    # this request will be signed with the Chimps user's Infochimps
    # API key and secret.  Signing a request which doesn't need to be
    # signed is just fine.  Forgetting to sign a request which needs
    # to be signed will result in a 401 error from Infochimps.
    #
    # If <tt>:sign_if_possible</tt> is passed in the +options+ then an
    # attemp to sign the URL will be made though an error will _not_
    # raise an error.
    #
    # @param [String] path
    # @param [Hash] options
    # @option options [Hash] query Query parameters to include in the URL
    # @option options [Hash] body Data to include in the request body
    # @option options [true, false] sign Sign this request, raising an error on failure
    # @option options [true, false] sign_if_possible Sign this request, no error on failure
    # @option potions [true, false] raw If raw then encoding the query string and request body is up to you.
    # @return [Chimps::Request]
    def initialize path, options={}
      self.path         = path
      self.query_params = options[:query_params] || options[:query]  || options[:params] || {}
      self.body         = options[:body]         || options[:data]   || {}

      @authentication_required      = [:authenticate, :authenticated, :authenticate_if_possible, :sign, :signed, :sign_if_possible].any? { |key| options[key] }
      @forgive_authentication_error = options[:sign_if_possible] || options[:authenticate_if_possible]
      @raw                          = options[:raw]
      authenticate_if_necessary!
      super(url_with_query_string, {:headers => DEFAULT_HEADERS.merge(options[:headers] || {})})
    end

    # Return the URL for this request with the (signed, if necessary)
    # query string appended.
    #
    # @return [String]
    def url_with_query_string
      if query_string && query_string.size > 0
        base_url + "?#{query_string}"
      else
        base_url
      end
    end
    
    # Should the request be authenticated?
    #
    # @return [true, false]
    def authenticate?
      @authentication_required
    end
    alias_method :sign?, :authenticate?

    # Should the query string and request body be encoded?
    #
    # Control this by passing in the <tt>:raw</tt> keyword when
    # initializing this Request.
    #
    # @return [true, false]
    def should_encode?
      !@raw
    end

    # Should this be considered a raw request in which neither the
    # query string nor the body should be encoded or escaped?
    #
    # @return [true, false]
    def raw?
      !!@raw
    end

    # Is this request authentiable (has the Chimps user specified an
    # API key and secret in their configuration file)?
    #
    # @return [true, false]
    def authenticable?
      Chimps.config[:apikey]
    end
    alias_method :signable?, :authenticable?

    # The host to send requests to.
    #
    # @return [String]
    def host
      @host ||= Chimps.config[:catalog][:host]
    end

    # Return the base URL for this request, consisting of the host and
    # path but *not* the query string.
    #
    # @return [String]
    def base_url
      File.join(host, path)
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
    def get options={}, &block
      handle_exceptions do
        Chimps.log.info("GET #{url}")
        Response.new(super(options, &block))
      end
    end

    # Perform a POST request to this URL, returning a parsed response.
    #
    # Any headers in +options+ will passed to
    # RestClient::Resource.post.
    #
    # @param [Hash] options
    # @return [Chimps::Response]
    def post options={}, &block
      handle_exceptions do
        Chimps.log.info("POST #{url}")
        Response.new(super(encoded_body, options, &block))
      end
    end

    # Perform a PUT request to this URL, returning a parsed response.
    #
    # Any headers in +options+ will passed to
    # RestClient::Resource.put.
    #
    # @param [Hash] options
    # @return [Chimps::Response]
    def put options={}, &block
      handle_exceptions do
        Chimps.log.info("PUT #{url}")
        Response.new(super(encoded_body, options, &block))
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
    def delete options={}, &block
      handle_exceptions do
        Chimps.log.info("DELETE #{url}")
        Response.new(super(options, &block))
      end
    end
    
    # Yield to +block+ but rescue any RestClient errors by wrapping
    # them in a Chimps::Response.
    def handle_exceptions &block
      begin
        yield
      rescue RestClient::Exception => e
        Response.new(e.response, :error => e.message)
      end
    end

    # Authenticate this request by stuffing the <tt>:requested_at</tt>
    # and <tt>:apikey</tt> properties into its <tt>:query_params</tt>
    # hash.
    #
    # Will do nothing at all if Chimps::Request#authenticate? returns
    # false.
    def authenticate_if_necessary!
      return unless authenticate? && should_encode?
      raise Chimps::AuthenticationError.new("API key (Chimps.config[:apikey]) missing from #{Chimps.config[:config]} or #{Chimps.config[:site_config]}") unless (authenticable? || @forgive_authentication_error)
      query_params[:requested_at] = Time.now.to_i.to_s
      query_params[:apikey]       = Chimps.config[:apikey]
    end

    # Return an unsigned query string for this request.
    #
    # @return [String]
    def unsigned_query_string
      (should_encode? ? RestClient::Payload.generate(query_params) : query_params).to_s
    end

    # Return an unsigned query string for this request without the
    # <tt>&</tt> and <tt>=</tt> characters.
    #
    # This is the text that will be signed for GET and DELETE
    # requests.
    #
    # @return [String]
    def unsigned_query_string_stripped
      @query_params_text ||= obj_to_stripped_string(query_params)
    end

    # Return this Requests's body as a suitably encoded string.
    #
    # This is the text that will be signed for POST and PUT requests.
    #
    # @return [String]
    def encoded_body
      @encoded_body ||= should_encode? ? encode(body) : body.to_s
    end

    def encode obj
      require 'json'
      JSON.generate((obj == true ? {} : obj), {:max_nesting => false})
    end

    # Sign +string+ by concatenting it with the secret and computing
    # the MD5 digest of the whole thing.
    #
    # @param [String]
    # @return [String]
    def sign string
      raise Chimps::AuthenticationError.new("No API Key stored in #{Chimps.config[:config]} or #{Chimps.config[:site_config]}.  Set Chimps.config[:apikey].") unless (authenticable? || @forgive_authentication_error)
      Chimps.config[:apikey]
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
      return unsigned_query_string unless should_encode?
      text_to_sign = ((body == true || (! body.empty?)) ? encoded_body : unsigned_query_string_stripped)
      signature    = sign(text_to_sign)
      "#{unsigned_query_string}&signature=#{signature}"
    end

    # Turn +obj+ into a string, sorting on internal keys.
    #
    # @param [Hash, Array, String] obj
    # @return [String]
    def obj_to_stripped_string obj
      case obj
      when Hash   then obj.keys.map(&:to_s).sort.map { |key| [key.to_s.downcase, obj_to_stripped_string(obj[key.to_sym])].join('') }.join('')
      when Array  then obj.map { |e| obj_to_stripped_string(e) }.join('')
      else             obj.to_s
      end
    end
    
  end
end
