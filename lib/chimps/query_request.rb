module Chimps
  
  # A class to encapsulate requests made against the Infochimps paid
  # query API.
  class QueryRequest < Request

    # Is this request authentiable (has the Chimps user specified an
    # API key and secret in their configuration file)?
    #
    # @return [true, false]
    def authenticable?
      Chimps.config[:apikey]
    end

    def url_with_query_string
      qs = (query_string && query_string.size > 0 ? query_string : nil)
      case
      when qs.nil?
        base_url
      when base_url.include?("?")
        base_url + "&#{qs}"
      else
        base_url + "?#{qs}"
      end
    end

    # The host to send requests to.
    #
    # @return [String]
    def host
      @host ||= Chimps.config[:query][:host]
    end

    # All Query API requests must be signed.
    #
    # @return [true]
    def authenticate?
      return true
    end

    # Authenticate this request by stuffing the <tt>:requested_at</tt>
    # and <tt>:apikey</tt> properties into its <tt>:query_params</tt>
    # hash.
    #
    # Will do nothing at all if Chimps::Request#authenticate? returns
    # false.
    def authenticate_if_necessary!
      return unless authenticate? && should_encode?
      raise Chimps::AuthenticationError.new("API key (Chimps.config[:apikey]) from #{Chimps.config[:config]} or #{Chimps.config[:site_config]}") unless authenticable?
      query_params[:requested_at] = Time.now.to_i.to_s # XXX This doesn't appear to be necessary
      query_params[:apikey]       = Chimps.config[:apikey]
    end
    
    # Append the signature to the unsigned query string.
    #
    # The signature made from the Chimps user's API Key and either
    # the query string text (stripped of <tt>&</tt> and <tt>=</tt>)
    # for GET and DELETE requests or the request body for POST and PUT
    # requests.
    #
    # @return [String]
    def signed_query_string
      unsigned_query_string
    end
    
  end
end
