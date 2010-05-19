require 'chimps/request'
require 'chimps/utils/uses_curl'
require 'chimps/workflows/uploader'

module Chimps
  module Workflows
    class BatchUpdater

      include Chimps::UsesCurl

      PATH = "batch.json"

      attr_reader :data, :output_file, :upload_even_if_errors, :batch_response

      def initialize data, options={}
        @data                  = data
        @output_file           = options[:output_file]
        @upload_even_if_errors = options[:upload_even_if_errors]
        @curl                  = options[:curl]
      end

      def execute!
        batch_update!
        batch_upload!
      end

      def batch_update!
        @batch_response = Request.new(PATH, :data => { :batch => data }, :authenticate => true).post
        File.open(output_file, 'w') { |f| f.puts batch_response.to_yaml } if output_file
        batch_response.print
      end

      def error?
        batch_response['batch'].each do |response|
          status = response['status']
          return true unless ['created', 'updated'].include?(status)
        end
        false
      end

      def success?
        ! error?
      end

      def batch_upload!
        if success? || upload_even_if_errors
          $stderr.puts("WARNING: continuing with uploads even though there were errors") if error?
          dataset_ids_and_local_paths.each do |id, local_paths|
            upload_response = Chimps::Workflows::Uploader.new(:dataset => id, :local_paths => local_paths, :curl => curl?).execute!
            upload_response.print if upload_response.error?
          end
        end
      end

      protected
      def dataset_ids_and_local_paths
        r = batch_response['batch'].map do |response|
          status = response['status']
          next unless (status == 'created' || status == 'updated')
          next unless dataset = response['resource']['dataset']
          id = dataset['id']
          next if id.blank?
          local_paths = response['local_paths']
          next if local_paths.blank?
          [id, local_paths]
        end.compact
      end
    end
  end
end
  
