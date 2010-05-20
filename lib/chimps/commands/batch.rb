module Chimps
  module Commands

    # A command for performing batch updates.
    class Batch < Chimps::Command

      BANNER = "usage: chimps batch [OPTIONS] [INPUT_PATH] ..."
      HELP   = <<EOF

Perform a batch operation on Infochimps by reading YAML input files.

The input files should collectively define an array of resources to
make create or update requests on.  Each request in the array is
treated separately (even though the entire array is processed as one
POST request) and so it is possible that some will succeed and others
fail.

It is also possible to upload data in this batch process.  Each
(successful) request which defined a 'local_paths' property in the
original input files will have the data at these paths uploaded to
Infochimps.  These uploads will proceed one at a time following the
initial batch POST request.

The format of the YAML input files is given at

  http://infochimps.org/api
EOF

      # A path to store the intermediate batch response.  Useful for
      # debugging.
      attr_accessor :output_path

      # Whether to continue to upload even if some of the resources
      # had errors on update/create.
      attr_accessor :upload_even_if_errors

      include Chimps::Utils::UsesYamlData

      def define_options
        on_tail("-o", "--output PATH", "Store the response from the server at PATH") do |o|
          @output_path = File.expand_path(o)
        end

        on_tail("-f", "--force", "Attempt to upload data even when there were errors in the batch update request") do |f|
          @upload_even_if_errors = f
        end
      end

      # Perform the batch update and upload.
      def execute!
        ensure_data_is_present!
        Chimps::Workflows::BatchUpdater.new(data, :output_path => output_path, :upload_even_if_errors => upload_even_if_errors).execute!
      end
      
    end
  end
end

