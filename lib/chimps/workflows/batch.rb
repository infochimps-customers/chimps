module Chimps
  module Workflows

    # A class for performing batch updates/uploads to Infochimps.
    #
    # It works by taking YAML data describing many updates and
    # performing a single batch API request with this data.
    #
    # The batch response is then parsed and analyzed and (given
    # success or fearlessness) any necessary uploads are performed.
    #
    # Examples of the input data format can be found in the
    # <tt>/examples</tt> directory of the Chimps distribution.
    class BatchUpdater

      include Chimps::Utils::UsesCurl

      # The data used sent as a bulk update.
      attr_reader :data

      # The batch update response
      attr_reader :batch_response

      # The output file to store the bulk update response.
      attr_reader :output_path

      # Whether to upload even if there were errors on update.
      attr_reader :upload_even_if_errors

      # Create a new BatchUpdater with the given +data+ and +options+.
      #
      # The intermediate batch response can be saved at a file named
      # by <tt>:output_path</tt>, though this isn't necessary.
      #
      # @param [Array] data an array of resource updates
      # @param [Hash] options
      # @option options [String] output_path path to store the batch response
      # @option options [true, false] upload_even_if_errors whether to continue uploading in the presence of errors on update
      # @return [Chimps::Workflows::BatchUpdater]
      def initialize data, options={}
        @data                  = data
        @output_path           = options[:output_path]
        @upload_even_if_errors = options[:upload_even_if_errors]
      end

      # The path to submit batch update requests.
      #
      # @return [String]
      def batch_path
        "batch.json"
      end

      # Perform this batch update followed by the batch upload.
      def execute!
        batch_update!
        batch_upload!
      end

      # Perform the batch update.
      def batch_update!
        @batch_response = Request.new(batch_path, :data => { :batch => data }, :authenticate => true).post
        File.open(output_path, 'w') { |f| f.puts batch_response.body } if output_path
        batch_response.print
      end

      # Were any of the updates performed during the batch update
      # errors?
      #
      # @return [true, false]
      def error?
        batch_response['batch'].each do |response|
          status = response['status']
          return true unless ['created', 'updated'].include?(status)
        end
        false
      end

      # Did all of the updates performed in the batch update succeed?
      #
      # @return [true, false]
      def success?
        ! error?
      end

      # Perform the batch upload.
      #
      # Will bail if the batch update had an error unless
      # Chimps::Workflows::BatchUpdater#upload_even_if_errors returns
      # true.
      def batch_upload!
        return unless success? || upload_even_if_errors
        $stderr.puts("WARNING: continuing with uploads even though there were errors") unless success?
        dataset_ids_and_local_paths.each do |id, local_paths|
          Chimps::Workflows::Uploader.new(:dataset => id, :local_paths => local_paths).execute!
        end
      end

      protected
      # Iterate through the batch response and return tuples
      # consisting of an ID and an array of of local paths to upload.
      #
      # Only datasets which were successfully created/updated,
      # returned an ID, and had local_paths defined in the original
      # batch update will be output.
      #
      # @return [Array<Array>]
      def dataset_ids_and_local_paths
        batch_response['batch'].map do |response|
          status = response['status']
          next unless (status == 'created' || status == 'updated') # skip errors
          next unless dataset = response['resource']['dataset']    # skip unless it's a dataset
          id = dataset['id']
          next if id.blank?                                        # skip unless it has an ID
          local_paths = response['local_paths']
          next if local_paths.blank?                               # skip unless local_paths were defined
          [id, local_paths]
        end.compact
      end
    end
  end
end
  
