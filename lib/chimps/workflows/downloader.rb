module Chimps
  module Workflows
    class Downloader

      include Chimps::Utils::UsesCurl

      # The token received from Infochimps which contains a signed URL
      # for the download.
      attr_reader :token
      
      attr_reader :dataset_id, :fmt, :pkg_fmt

      def initialize options={}
        @dataset_id = options[:dataset_id]
        @fmt        = options[:fmt]
        @pkg_fmt    = options[:pkg_fmt]
        @local_path = options[:local_path]
      end

      # Params to send for the token.
      def token_params
        { :download_token => { :dataset_id => dataset_id, :fmt =>  fmt, :pkg_fmt => pkg_fmt} }
      end

      # Ask for a download token for this dataset/package.  If no or
      # an invalid token is obtained, raise an error.
      def ask_for_token!
        new_token = Request.new(download_tokens_path, :data => token_params, :sign_if_possible => true).post
        raise AuthenticationError.new("Cannot obtain token for dataset #{dataset_identifier}") if new_token.error?
        @token = new_token
      end

      # Path to submit download token requests to.
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
        download_with_curl!
      end

      def download_with_curl!
        command = "#{curl} -o '#{local_path}' '#{download_url}'"
        puts command if Chimps.verbose?
        system(command)
      end

      def execute!
        ask_for_token!
        download!
      end

    end
  end
end
