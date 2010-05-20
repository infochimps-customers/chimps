module Chimps
  module Commands

    # A command for uploading data to Infochimps.
    class Upload < Chimps::Command

      BANNER = "usage: chimps upload [OPTIONS] ID_OR_HANDLE PATH [PATH] ..."
      HELP   = <<EOF

Upload data from your local machine for an existing dataset identified
by ID_OR_HANDLE on Infochimps.

chimps will package all paths supplied into a local archive and then
upload this archive to Infochimps.  The local archive defaults to a
sensible name in the current directory but can also be customized.

If the only file to be packaged is already a package (.zip, .tar,
.tar.gz, &.c) then it will not be packaged again.
EOF

      # The path to the archive
      attr_reader :archive

      # The ID or handle of the dataset to upload data for.
      #
      # @return [String]
      def dataset
        raise CLIError.new("Must provide an ID or URL-escaped handle as the first argument") if argv.first.blank?
        argv.first
      end

      # A list of local paths to upload.
      #
      # @return [Array<String>]
      def local_paths
        raise CLIError.new("Must provide some paths to upload") if argv.length < 2
        argv[1..-1]
      end
      
      def define_upload_options
        on_tail("-a", "--archive-path", "Path to the archive to be created.  Defaults to a timestamped ZIP file named after the dataset in the current directory.") do |path|
          @archive = path
        end
      end

      # Upload the data.
      def execute!
        Chimps::Workflows::Uploader.new(:dataset => dataset, :archive => archive, :local_paths => local_paths).execute!
      end
    end
  end
end

