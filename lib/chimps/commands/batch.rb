module Chimps
  module Commands

    # A command for performing batch updates.
    class Batch < Chimps::Command

      USAGE = "usage: chimps batch [OPTIONS] [INPUT_PATH] ..."
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

      include Chimps::Utils::UsesYamlData

      # Perform the batch update and upload.
      def execute!
        ensure_data_is_present!
        Chimps::Workflows::BatchUpdater.new(data, :output_path => config[:output], :upload_even_if_errors => config[:force], :fmt => config[:format]).execute!
      end
      
    end
  end
end

