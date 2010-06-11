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
.tar.gz, &c.) then it will not be packaged again.

Supplied paths are allowed to be remote files so someting like

  chimps upload my-dataset path/to/local/file.txt http://my-site.com/path/to/remote/file.txt

will work.
EOF

      # The path to the archive
      attr_reader :archive

      # The data format to annotate the upload with.
      #
      # Chimps will try to guess if this isn't given.
      attr_reader :fmt

      # The ID or handle of the dataset to upload data for.
      #
      # @return [String]
      def dataset
        raise CLIError.new("Must provide an ID or URL-escaped handle as the first argument") if argv.first.blank?
        argv.first
      end

      # A list of paths to upload.
      #
      # @return [Array<String>]
      def paths
        raise CLIError.new("Must provide some paths to upload") if argv.length < 2
        argv[1..-1]
      end
      
      def define_upload_options
        on_tail("-a", "--archive-path", "Path to the archive to be created.  Defaults to a timestamped ZIP file named after the dataset in the current directory.") do |path|
          @archive = path
        end

        on_tail("-f", "--format FORMAT", "Data format to annotate upload with.  Tries to guess if not given.") do |f|
          @fmt = f
        end
          
      end

      # Upload the data.
      def execute!
        Chimps::Workflows::Up.new(:dataset => dataset, :archive => archive, :paths => paths, :fmt => fmt).execute!.print
      end
    end
  end
end

