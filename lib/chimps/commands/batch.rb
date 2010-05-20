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

      attr_accessor :output_file, :upload_even_if_errors

      include Chimps::Utils::UsesCurl

      def define_options
        on_tail("-o", "--output PATH", "Store the response from the server at PATH") do |o|
          @output_file = File.expand_path(o)
        end

        on_tail("-f", "--force", "Attempt to upload data even when there were errors in the batch update request") do |f|
          @upload_even_if_errors = f
        end
      end

      def execute!
        Chimps::Workflows::BatchUpdater.new(data, :output_file => output_file, :upload_even_if_errors => upload_even_if_errors, :curl => curl?).execute!
      end
      

      protected

      #
      # Read data from input YAML to pass to BatchUpdater
      #

      def input_documents_from_command_line
        argv.map { |path| YAML.load_file(File.expand_path(path)) }
      end

      def input_documents_from_stdin
        return [] unless $stdin.stat.size > 0
        YAML.load_stream($stdin)
      end

      def data
        docs = input_documents_from_command_line + input_documents_from_stdin
        raise CLIError.new("Must provide some input data") if docs.blank?
        returning([]) do |data|
          docs.each do |doc|
            raise CLIError.new("All input data must consist of arrays of mappings") unless doc.is_a?(Array)
            data.concat(doc)
          end
        end
      end

    end
  end
end

