module Chimps
  module Workflows
    module Upload

      # Encapsulates the process of analyzing and bundling input
      # paths.
      class Bundler

        #
        # == Initialization & Attributes
        #
        
        # Instantiate a new Bundler for bundling +paths+ as a package
        # for +dataset+.
        #
        # Each input path can be either a String or an IMW::Resource
        # identifying a local or remote resource to bundle into an
        # upload package for Infochimps (remote resources will be
        # first copied to the local filesystem by IMW).
        #
        # If no format is given the format will be guessed by IMW.
        #
        # If not archive is given the archive path will be set to a
        # timestamped named in the current directory, see
        # Bundler#default_archive_path.
        #
        # @param [String, Integer] dataset the ID or slug of an existing Infochimps dataset
        # @param [Array<String, IMW::Resource>] paths
        # @param [Hash] options
        # @option options [String] fmt the format (csv, tsv, xls, &c.) of the data being uploaded
        # @option options [String, IMW::Resource] archive the path to the local archive to package the input paths into
        def initialize dataset, paths, options={}
          require_imw
          @dataset     = dataset
          self.paths   = paths
          if options[:fmt]
            self.fmt     = options[:fmt]
          end
          if options[:archive]
            self.archive = options[:archive]
          end
        end

        # The dataset this bundler is processing data for.
        attr_accessor :dataset

        # The paths this bundler is processing.
        attr_reader :paths

        # The resources this bundler is processing.
        #
        # Resources are IMW::Resource objects built from this
        # Bundler's paths.
        attr_reader :resources
        
        # Set the paths for this Bundler.
        #
        # If only one input path is given and it is already an archive
        # or a compressed file then no packaging will be attempted.
        # Otherwise the input paths will be packaged together
        #
        # @param [Array<String, IMW::Resource>] new_paths
        def paths= new_paths
          raise PackagingError.new("Must provide at least one path to upload.") if new_paths.blank?
          @paths, @resources = [], []

          new_paths.each do |path|
            resource = IMW.open(path)
            resource.should_exist!("Cannot bundle.") if resource.is_local?
            @paths     << path
            @resources << resource
          end
          
          if resources.size == 1
            potential_package = resources.first
            if potential_package.is_local? && potential_package.exist? && (potential_package.is_compressed? || potential_package.is_archive?)
              self.archive = potential_package
              @skip_packaging = true
            end
          end
        end
        
        # The format of the data being bundled.
        attr_writer :fmt

        # The format of the data being bundled.
        #
        # Will make a guess using IMW::Tools::Summarizer if no format
        # is given.
        def fmt
          @fmt ||= summarizer.most_common_data_format
        end
        
        # The archive this bundler will build for uploading to
        # Infochimps.
        #
        # @return [IMW::Resource]
        def archive
          return @archive if @archive
          self.archive = default_archive_path
          self.archive
        end

        # Set the path to the archive that will be built.
        #
        # The given +path+ must represent a compressed file or archive
        # (<tt>.tar</tt>, <tt>.tar.gz.</tt>, <tt>.tar.bz2</tt>,
        # <tt>.zip</tt>, <tt>.rar</tt>, <tt>.bz2</tt>, or <tt>.gz</tt>
        # extension).
        #
        # Additionally, if multiple local paths are being packaged, the
        # given +path+ must be an archive (not simply <tt>.bz2</tt> or
        # <tt>.gz</tt> extensions).
        #
        # @param [String, IMW::Resource] path_or_obj the obj or IMW::Resource object pointing to the archive to use
        def archive= path_or_obj
          potential_package = IMW.open(path_or_obj)
          raise PackagingError.new("Invalid path #{potential_package}, not an archive or compressed file")        unless potential_package.is_compressed? ||  potential_package.is_archive?
          raise PackagingError.new("Multiple local paths must be packaged in an archive, not a compressed file.") if     resources.size > 1               && !potential_package.is_archive?
          @archive = potential_package
        end

        # Return the package format of this bundler's archive, i.e. -
        # its extension.
        # 
        # @return [String]
        def pkg_fmt
          archive.extension
        end

        # Return the total size of the package after aggregating and
        # packaging.
        #
        # @return [Integer]
        def size
          archive.size
        end

        # Return summary information about the package prepared by the
        # bundler.
        #
        # @return [Hash]
        def summary
          summarizer.summary
        end
        
        # Bundle the data for this bundler together.
        def bundle!
          return if skip_packaging?
          result = archiver.package(archive.path)
          raise PackagingError.new("Unable to package files for upload.  Temporary files left in #{archiver.tmp_dir}") if result.is_a?(StandardError) || (!archiver.success?)
          archiver.clean!
        end
        
        #
        # == Helper Objects ==
        #

        # The IMW::Tools::Archiver responsible for packaging files
        # into a local archive.
        #
        # @return [IMW::Tools::Archiver]
        def archiver
          @archiver ||= IMW::Tools::Archiver.new(archive.name, paths_to_bundle)
        end

        # Return the summarizer responsible for summarizing data on this
        # upload.
        #
        # @return [IMW::Tools::Summarizer]
        def summarizer
          @summarizer ||= IMW::Tools::Summarizer.new(resources)
        end

        # Should the packaging step be skipped?
        #
        # This will happen if only one local input path was provided and
        # it exists and is a compressed file or archive.
        #
        # @return [true, false]
        def skip_packaging?
          !! @skip_packaging
        end

        #
        # == Paths & URLs == 
        #

        # The default path to the archive that will be built.
        #
        # Defaults to a file in the current directory named after the
        # +dataset+'s ID or handle and the current time.  The package
        # format (<tt>.zip</tt> or <tt>.tar.bz2</tt>) is determined by
        # size, see
        # Chimps::Workflows::Uploader#default_archive_extension.
        #
        # @return [String]
        def default_archive_path
          # in current working directory...
          "chimps_#{dataset}-#{Time.now.strftime(Chimps::CONFIG[:timestamp_format])}.#{default_archive_extension}"
        end

        # end <tt>zip</tt> if the data is less than 500 MB in size and
        # <tt>tar.bz2</tt> otherwise.
        #
        # @return ['tar.bz2', 'zip']
        def default_archive_extension
          summarizer.total_size >= 524288000 ? 'tar.bz2' : 'zip'
        end

        # The URL to the <tt>README-infochimps</tt> file on Infochimps'
        # servers.
        #
        # @return [String]
        def readme_url
          File.join(Chimps::CONFIG[:site][:host], "/README-infochimps")
        end

        # The URL to the ICSS file for this dataset on Infochimps
        # servers
        def icss_url
          File.join(Chimps::CONFIG[:site][:host], "datasets", "#{dataset}.yaml")
        end

        # Both the local paths and remote paths to package.
        #
        # @return [Array<String>]
        def paths_to_bundle
          paths + [readme_url, icss_url]
        end

        protected
        # Require IMW and match the IMW logger to the Chimps logger.
        def require_imw
          begin
            require 'imw'
            IMW.log = Chimps.log
            IMW.verbose = Chimps.verbose?
          rescue LoadError
            raise Chimps::Error.new("The Infinite Monkeywrench (IMW) gem is required to upload.")
          end
        end
        
      end

    end
  end
end

