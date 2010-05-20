require 'cgi'
require 'digest/md5'
require 'restclient'

require 'chimps/response'
require 'chimps/utils'

module Chimps

  class Request < RestClient::Resource

    CONTENT_TYPE = { :content_type => 'application/json', :accept => 'application/json' }

    attr_accessor :path, :query_params, :data

    def initialize path, options={}
      @path         = path
      @query_params = options[:query_params] || options[:params] || {}
      @data         = options[:data]         || {}
      @authentication_required      = [:authenticate, :authenticated, :authenticate_if_possible, :sign, :signed, :sign_if_possible].any? { |key| options.include?(key) }
      @forgive_authentication_error = options[:sign_if_possible] || options[:authenticate_if_possible]
      authenticate_if_necessary!
      super url_with_query_string
    end

    def authenticate?
      @authentication_required
    end
    alias_method :sign?, :authenticate?

    def authenticable?
      !Chimps::CONFIG[:api_key].blank? && !Chimps::CONFIG[:api_secret].blank?
    end
    alias_method :signable?, :authenticable?

    def url_with_query_string
      base_url = File.join(Chimps::CONFIG[:host], path)
      base_url += "?#{query_string}" unless query_string.blank?
      base_url
    end

    def query_string
      (authenticate? && authenticable?) ? signed_query_string : unsigned_query_string
    end

    def get options={}
      handle_exceptions do
        puts "GET #{url}" if Chimps.verbose?
        Chimps::Response.new(super(CONTENT_TYPE.merge(options)))
      end
    end

    def post options={}
      handle_exceptions do
        puts "POST #{url}" if Chimps.verbose?
        Chimps::Response.new(super(data_text, CONTENT_TYPE.merge(options)))
      end
    end

    def put options={}
      handle_exceptions do
        puts "PUT #{url}" if Chimps.verbose?
        Chimps::Response.new(super(data_text, CONTENT_TYPE.merge(options)))
      end
    end

    def delete options={}
      handle_exceptions do
        puts "DELETE #{url}" if Chimps.verbose?
        Chimps::Response.new(super(CONTENT_TYPE.merge(options)))
      end
    end
    
    protected
    def handle_exceptions &block
      begin
        yield
      rescue RestClient::NotModified, RestClient::Unauthorized, RestClient::ResourceNotFound, RestClient::RequestFailed => e
        return Response.new(e)
      end
    end
    
    def authenticate_if_necessary!
      return unless authenticate?
      raise Chimps::AuthenticationError.new("API key or secret missing from #{CONFIG[:identity_file]}") unless (authenticable? || @forgive_authentication_error)
      query_params[:requested_at] = Time.now.to_i.to_s
      query_params[:api_key]      = Chimps::CONFIG[:api_key]
    end

    def alphabetical_params
      query_params.keys.map(&:to_s).sort
    end

    # This string goes in the URL.  The params have to be ordered
    # alphabetically
    #
    #   apple=delicious&zebra=crazy
    def unsigned_query_string
      alphabetical_params.map { |key| "#{CGI::escape(key.to_s)}=#{CGI::escape(query_params[key.to_sym].to_s)}" }.join("&")
    end

    # This string is used to sign the query string.  No = or &.
    #
    #   appledeliciouszebracrazy
    def query_params_text
      @query_params_text ||= alphabetical_params.map { |key| CGI::escape(key.to_s) + CGI::escape(query_params[key.to_sym].to_s) }.join('')
    end

    def data_text
      @data_text ||= data.to_json
    end

    # Sign +string+ by concatenting it with the secret and computing
    # the MD5 digest of the whole thing.
    def sign string
      raise Chimps::AuthenticationError.new("No API secret stored in #{CONFIG[:identity_file]}.") unless (authenticable? || @forgive_authentication_error)
      Digest::MD5.hexdigest(string + CONFIG[:api_secret])
    end

    # Append the signature to the unsigned query string.
    def signed_query_string
      signature = sign(data.blank? ? query_params_text : data_text)
      "#{unsigned_query_string}&signature=#{signature}"
    end

  end
end

