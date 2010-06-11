module Chimps
  module Workflows
    module Upload

      # Encapsulates the process of uploading a package to Infochimps.
      class Uploader

        include Chimps::Utils::UsesCurl

        # The token consumed when uploading.
        attr_accessor :token

        # The bundler from which to glean information about the upload.
        attr_accessor :bundler

        # Instantiate a new Uploader which will consume the given
        # +token+ and upload data from the given +bundler+.
        #
        # @param [Chimps::Workflows::Upload::UploadToken] token
        # @param [Chimps::Workflows::Upload::Bundler] bundler
        def initialize token, bundler
          self.token   = token
          self.bundler = bundler
        end

        # Return a string built from the granted upload token that can
        # be fed to +curl+ in order to authenticate with and upload to
        # Amazon.
        #
        # @return [String]
        def upload_data
          data = ['AWSAccessKeyId', 'acl', 'key', 'policy', 'success_action_status', 'signature'].map { |param| "-F #{param}='#{token[param]}'" }
          data << ["-F file=@#{bundler.archive.path}"]
          data.join(' ')
        end

        # Upload the data.
        #
        # Uses +curl+ for the transfer.
        def upload!
          progress_meter = Chimps.verbose? ? '' : '-s -S'
          command = "#{curl} #{progress_meter} -o /dev/null -X POST #{upload_data} #{token['url']}"
          puts command if Chimps.verbose?
          raise UploadError.new("Failed to upload #{bundler.archive.path} to Infochimps") unless system(command)
        end

      end
    end
  end
end

