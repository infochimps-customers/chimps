module Chimps
  module Commands

    # A command to download data from Infochimps.
    class Download < Chimps::Command

      BANNER = "usage: chimps download [OPTIONS] ID_OR_HANDLE"
      HELP   = <<EOF

Download a dataset identified by the given ID_OR_HANDLE to the current
directory (you can also specify a particular path).

If the dataset isn't freely downloadable, you'll have to have
purchased it first via the Web.
EOF

      # The chosen data format.
      attr_reader :fmt

      # The chosen package format.
      attr_reader :pkg_fmt

      # The local path to download the data to.
      attr_reader :local_path
      
      # Set the format for the download token.
      #
      # Will try to normalize the input somewhat (downcasing,
      # stripping leading periods)
      #
      # @param [String] new_fmt
      def fmt= new_fmt
        @fmt = new_fmt.downcase.strip.gsub(/^\./, '')
      end

      # Set the package format for the download token.
      # 
      # Will try to normalize the input somewhat (downcasing,
      # stripping leading periods)
      #
      # @param [String] new_pkg_fmt
      def pkg_fmt= new_pkg_fmt
        @pkg_fmt = new_pkg_fmt.downcase.strip.gsub(/^\./, '')
      end
      
      # The ID of the package to download.
      def dataset_identifier
        raise CLIError.new("Must provide an ID_OR_HANDLE of a dataset to download.") if argv.first.blank?
        argv.first
      end

      # Issue the request for the token and the request for the
      # download.
      def execute!
        Chimps::Workflows::Downloader.new(:dataset_id => dataset_identifier, :fmt => fmt, :pkg_fmt => pkg_fmt, :local_path => local_path).execute!
      end

      def define_options
        on_tail("-o", "--output PATH", "Path to download file to") do |o|
          @local_path = File.expand_path(o)
        end

        on_tail("-f", "--format FORMAT", "Choose a particular data format (csv, tsv, excel, &c.)") do |f|
          self.fmt = f
        end

        on_tail("-p", "--package PACKAGE", "Choose a particular package type (zip or tar.bz2)") do |p|
          self.pkg_fmt = p
        end
        
      end
      
    end
  end
end

