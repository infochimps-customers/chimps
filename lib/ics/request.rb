require 'cgi'
require 'digest/md5'
require 'ics/response'
require 'restclient'

module ICS

  AuthenticationError = Class.new(StandardError)
  
  class Request < RestClient::Resource

    attr_accessor :path, :query_params, :data

    def initialize path, options={}
      @path         = path
      @query_params = options[:query_params] || options[:params] || {}
      @data         = options[:data]         || {}
      @authentication_required = options[:authenticate] || options[:authenticated] || options[:sign] || options[:signed]
      authenticate_if_necessary!
      super url_with_query_string
    end

    def authenticate?
      @authentication_required
    end
    alias_method :authenticated?, :authenticate?
    alias_method :signed?, :authenticate?
    alias_method :sign?, :authenticate?
    
    def url_with_query_string
      base_url = File.join(ICS::CONFIG[:host], path)
      base_url += "?#{query_string}" unless query_string.blank?
      base_url
    end

    def query_string
      authenticate? ? signed_query_string : unsigned_query_string
    end

    def get
      ICS::Response.new(super)
    end

    protected
    def authenticate_if_necessary!
      return unless authenticate?
      raise ICS::AuthenticationError.new("No API key stored in #{CONFIG[:identity_file]}, .") if CONFIG[:api_key].blank?
      query_params[:api_key] = CONFIG[:api_key]
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
      alphabetical_params.map { |key| CGI::escape(key.to_s) + CGI::escape(query_params[key.to_sym].to_s) }.join('')
    end

    # Sign +string+ by concatenting it with the secret and computing
    # the MD5 digest of the whole thing.
    def sign string
      raise ICS::AuthenticationError.new("No API secret stored in #{CONFIG[:identity_file]}.") if CONFIG[:api_secret].blank?
      Digest::MD5.hexdigest(string + CONFIG[:api_secret])
    end

    # Append the signature to the unsigned query string.
    def signed_query_string
      "#{unsigned_query_string}&signature=#{sign(query_params_text)}"
    end

  end
end

