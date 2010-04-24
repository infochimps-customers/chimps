require 'ics/commands/base'
require 'ics/utils/uses_curl'
require 'ics/workflows/uploader'

module ICS
  module Commands

    class Upload < ICS::Command

      BANNER = "usage: ics upload [OPTIONS] ID_OR_HANDLE PATH [PATH] ..."
      HELP   = <<EOF

Upload data from your local machine for an existing dataset identified
by ID_OR_HANDLE on Infochimps.

ics will package all paths supplied into a local archive and then
upload this archive to Infochimps.  The local archive defaults to a
sensible name in the current directory but can also be customized.
EOF

      attr_reader :user_defined_archive_path

      include ICS::UsesCurl

      def define_upload_options
        on_tail("-a", "--archive-path", "Path to the archive to be created.  Defaults to a timestamped ZIP file named after the dataset in the current directory.") do |path|
          @user_defined_archive_path = path
        end
      end
      def execute!
        ICS::Workflows::Uploader.new(:dataset => dataset, :archive_path => user_defined_archive_path, :local_paths => local_paths, :curl => curl?).execute!.print
      end

      #
      # Parse command line so it can be passed to Uploader
      #

      def dataset
        raise CLIError.new("Must provide an ID or URL-escaped handle as the first argument") if argv.first.blank?
        argv.first
      end
      
      def local_paths
        raise CLIError.new("Must provide some paths to upload") if argv.length < 2
        argv[1..-1]
      end

    end
  end
end

