module Chimps
  module Workflows
    module Upload

      # Encapsulates the process of obtaining an upload token for a
      # dataset from Infochimps.
      class UploadToken

        # The ID or slug of the dataset for which to obtain an upload
        # token.
        attr_accessor :dataset

        # The format (csv, xls, tsv, &c.) of the data in the upload.
        attr_accessor :fmt

        # The package format (zip, tar.bz2, &c.)  of the data in the
        # upload.
        attr_accessor :pkg_fmt

        # The response from Infochimps to the request for an upload
        # token.
        attr_accessor :response

        # Instantiate a new UploadToken for the given +dataset+ with
        # the given +fmt+ and +pkg_fmt+.
        #
        # @param [String,Integer] dataset the ID or slug of the dataset to upload data for
        # @param [String] fmt the data format (csv, xls, tsv, &c.) of the data
        # @param [String] pkg_fmt the package format (zip, tar.bz2, tar.gz, &c.) of the data
        def initialize dataset, options={}
          @dataset = dataset
          @fmt     = options[:fmt]
          @pkg_fmt = options[:pkg_fmt]
        end

        # Delegate slicing to the returned response.
        def [] param
          response && response[param]
        end
          
        # The path on Infochimps to submit upload token requests to.
        #
        # @return [String]
        def path
          "/datasets/#{dataset}/packages/new.json"
        end

        # Parameters passed to Infochimps to request an upload token.
        #
        # @return [Hash]
        def params
          { :package => { :fmt => fmt, :pkg_fmt => pkg_fmt } }
        end

        # Make the request to get an upload token from Infochimps
        def get
          @response = Request.new(path, :params => params, :signed => true).get
          if response.error?
            response.print
            raise AuthenticationError.new("Unauthorized for an upload token for dataset #{dataset}")
          end
        end
      end
    end
  end
end

      
