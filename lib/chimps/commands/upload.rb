module Chimps
  module Commands

    # A command for uploading data to Infochimps.
    class Upload < Chimps::Command

      USAGE  = "usage: chimps upload [OPTIONS] ID_OR_HANDLE PATH [PATH] ..."
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

      # The ID or handle of the dataset to upload data for.
      #
      # @return [String]
      def dataset
        raise CLIError.new("Must provide an ID or URL-escaped handle as the first argument") if config.argv.first.blank?
        config.argv.first
      end

      # A list of paths to upload.
      #
      # @return [Array<String>]
      def paths
        raise CLIError.new("Must provide some paths to upload") if config.argv.length < 2
        config.argv[1..-1]
      end
      
      # Upload the data.
      def execute!
        Chimps::Workflows::Up.new(:dataset => dataset, :archive => config[:archive], :paths => paths, :fmt => config[:format]).execute!.print
      end
    end
  end
end

