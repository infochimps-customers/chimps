module Chimps
  module Workflows

    # Downloads data from Infochimps by first making a request for a
    # download token and, if granted one, proceeding to download the
    # data.
    #
    # Will download the latest package for a given dataset, optionally
    # constrained to have given data and package formats.
    class Downloader

      include Chimps::Utils::UsesCurl

      # The token received from Infochimps which contains a signed URL
      # for the download.
      attr_reader :token

      # The ID or handle of the dataset to download.
      attr_reader :dataset

      # The data format of the data to download.
      attr_reader :fmt

      # The package format of the data to download.
      attr_reader :pkg_fmt

      # Create a new Downloader with the given parameters.
      #
      # @param [Hash] options
      # @option options [String, Integer] dataset the ID or handle of the dataset to download
      # @option options [String] fmt the data format to download
      # @option options [String] pkg_fmt the package format to download
      # @option options [String] local_path the local path to which the data will be downloaded
      # @return [Chimps::Workflows::Downloader]
      def initialize options={}
        @dataset    = options[:dataset]
        @fmt        = options[:fmt]
        @pkg_fmt    = options[:pkg_fmt]
        @local_path = options[:local_path]
      end

      # Params to send for the token.
      #
      # @return [Hash]
      def token_params
        { :download_token => { :dataset_id => dataset, :fmt =>  fmt, :pkg_fmt => pkg_fmt} }
      end

      # Ask for a download token for this dataset/package.  If no or
      # an invalid token is obtained, raise an error.
      def ask_for_token!
        new_token = Request.new(download_tokens_path, :data => token_params, :sign_if_possible => true).post
        if new_token.error?
          new_token.print
          raise AuthenticationError.new("Unauthorized to download dataset #{dataset}")
        else
          @token = new_token
        end
      end

      # Path to submit download token requests to.
      #
      # @return [String]
      def download_tokens_path
        "/download_tokens"
      end
        
      # The signed, remote URL from where the data can be downloaded.
      #
      # @return [String]
      def download_url
        token['download_token']['package']['url']
      end

      # The local path where the downloaded data will be put.
      #
      # Defaults to the current directory and the default basename of
      # the downloaded package.
      #
      # @return [String, nil]
      def local_path
        @local_path || token["download_token"]["package"]["basename"]
      end

      # Issue the download request.
      #
      # Uses +curl+ for the data transfer.
      def download!
        command = "#{curl} -o '#{local_path}' '#{download_url}'"
        puts command if Chimps.verbose?
        system(command)
      end

      # Ask for a token and perform the download.
      def execute!
        ask_for_token!
        download!
      end

    end
  end
end
