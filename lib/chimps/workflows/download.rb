module Chimps

  # A download is composted of an initial POST request which obtains a
  # signed and expiring token from Infochimps followed by a GET to the
  # URL provided in the token.
  class Download

    # The slug or (ID) of the dataset to download
    attr_accessor :dataset

    # Provides the use of curl to download the file.
    include Chimps::Utils::UsesCurl

    # Create a new download for the dataset named by the given slug or
    # ID.
    #
    # @param [String] dataset
    def initialize dataset
      self.dataset = dataset
    end

    # Download data to +path+.
    #
    # If +path+ is a directory then the resulting file will be put
    # there with a basename determined sensibly from +signed_url+.
    # Otherwise it will be placed at +path+ itself.
    #
    # @param [String] path
    # @return [Integer] the exit code of the curl command used to download the data
    def download path
      if File.directory?(path)
        basename = File.basename(signed_url).split('?').first
        path     = File.join(path, basename)
      end
      curl signed_url, :output => path
    end

    # The request for obtaining a download token from Infochimps.
    #
    # @return [Chimps::Request]
    def token_request
      @token_request ||= Request.new("/datasets/#{dataset}/downloads", :sign_if_possible => true)
    end

    # A download token from Infochimps containing a signed URL from
    # which data can be downloaded.
    #
    # @return [Chimps::Response]
    def token
      @token ||= token_request.post do |response, request, result, &block|
        case response.code
        when 301, 302, 307
          response.follow_redirection(request, result, &block)
        when 200
          response.return!(request, result, &block)
        else
          raise Error.new("Could not obtain download token from Infochimps")
        end
      end
    end

    # Return the signed URL as parsed from the download token.
    #
    # @return [String] the token's signed URL
    def signed_url
      token.parse
      raise Error.new("Malformed download token received from Infochimps") unless token['download_token'].is_a?(Hash) && token['download_token']['signed_url']
      token['download_token']['signed_url']
    end
    
  end
end
