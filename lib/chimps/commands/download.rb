module Chimps
  module Commands

    # A command to download data from Infochimps.
    class Download < Chimps::Command

      USAGE = "usage: chimps download [OPTIONS] ID_OR_HANDLE"
      HELP   = <<EOF

Download a dataset identified by the given ID_OR_HANDLE to the current
directory (you can also specify a particular path).

If the dataset isn't freely downloadable, you'll have to have
purchased it first via the Web.
EOF

      # Return the given string downcased and stripped of leading
      # periods.
      #
      # @param [String] string
      # @return [String, nil]
      def normalize string
        return string if string.blank?
        string.downcase.strip.gsub(/^\./, '')
      end
      
      # The ID of the package to download.
      def dataset
        raise CLIError.new("Must provide an ID or handle of a dataset to download.") if config.argv.first.blank?
        config.argv.first
      end

      def local_path
        config[:output].blank? ? config[:output] : File.expand_path(config[:output])
      end

      # Issue the request for the token and the request for the
      # download.
      def execute!
        Chimps::Workflows::Downloader.new(:dataset => dataset, :fmt => normalize(config[:format]), :pkg_fmt => normalize(config[:pkg_fmt]), :local_path => local_path).execute!
      end
      
    end
  end
end

