module Chimps
  module Workflows
    module Upload

      # Encapsulates the process of notifying Infochimps of new data
      # that's already been uploaded.
      class Notifier

        # The response from Infochimps to the request to create a
        # package.
        attr_accessor :response

        # The upload token used for the upload.
        attr_accessor :token

        # The bundler responsible for the upload.
        attr_accessor :bundler

        def initialize token, bundler
          self.token   = token
          self.bundler = bundler
        end

        # The path on Infochimps to submit package creation requests
        # to.
        #
        # @return [String]
        def path
          "/datasets/#{bundler.dataset}/packages.json"
        end

        # Information about the uplaoded data to pass to Infochimps
        # when notifying.
        #
        # @return [Hash]
        def data
          { :package => {:fmt => token['fmt'], :pkg_size => bundler.size, :pkg_fmt => bundler.pkg_fmt, :summary => bundler.summary, :token_timestamp => token['timestamp'] } }
        end

        # Make a request to notify Infochimps of the new data.
        #
        # @return [Chimps::Response]
        def post
          @response = Request.new(path, :signed => true, :data => data).post
          if response.error?
            response.print
            raise UploadError.new("Unable to notify Infochimps of newly uploaded data.")
          end
          response
        end
      end
    end
  end
end


        


