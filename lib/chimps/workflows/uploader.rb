module Chimps
  module Workflows

    # Uploads data to Infochimps by first asking for authorization,
    # creating an archive, obtaining a token, uploading data, and
    # notifing Infochimps.
    class Uploader

      include Chimps::Utils::UsesCurl

      # The ID or handle of the dataset to download.
      attr_reader :dataset

      # An array of paths to local files and directories to package
      # into an archive.
      attr_reader :local_paths

      # The format to annotate the upload with.
      attr_reader :fmt
      
      # The archive to upload.
      attr_reader :archive
      
      # The token authoring an upload.
      attr_reader :token

      # Upload data to Infochimps by first asking for authorization,
      # creating an archive, obtaining a token, uploading data, and
      # notifing Infochimps.
      def execute!
        authorize_for_upload!
        create_archive!
        ask_for_token!
        upload!
        notify_infochimps!
      end

      # Create a new Uploader from the given parameters.
      #
      # If <tt>:fmt</tt> is provided it will be used as the data
      # format to annotate the upload with.  If not, Chimps will try
      # to guess.
      #
      # @param [Hash] options
      # @option options [String, Integer] dataset the ID or handle of the dataset to which data should be uploaded
      # @option options [Array<String>] local_paths the local paths to bundle into an archive      
      # @option options [String, IMW::Resource] archive the path to the archive to create (defaults to IMW::Workflows::Downloader#default_archive_path)
      # @option options [String] fmt the data format to annotate the upload with
      def initialize options={}
        require_imw
        @dataset         = options[:dataset] or raise PackagingError.new("Must provide the ID or handle of a dataset to upload data to.")
        self.local_paths = options[:local_paths]   # must come before self.archive=
        self.archive     = options[:archive]
        self.fmt         = options[:fmt]
      end

      # Set the local paths to upload for this dataset.
      #
      # If only one local path is given and it is already an archive
      # or a compressed file then no further packaging will be done by
      # this uploader.
      #
      # @param [Array<String, IMW::Resource>] paths
      def local_paths= paths
        raise PackagingError.new("Must provide at least one local path to upload.") if paths.blank?
        paths.each { |path| raise PackagingError.new("Invalid path, #{path}") unless File.exist?(File.expand_path(path)) }
        @local_paths = paths
        if @local_paths.size == 1
          potential_package = IMW.open(paths.first)
          if potential_package.exist? && (potential_package.is_compressed? || potential_package.is_archive?)
            self.archive = potential_package
            @skip_packaging = true
          end
        end
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
      # @param [String, IMW::Resource] path the archive or path to use
      def archive= path=nil
        return @archive if @archive
        potential_package = IMW.open(path || default_archive_path)
        raise PackagingError.new("Invalid path #{potential_package}, not an archive or compressed file")        unless potential_package.is_compressed? ||  potential_package.is_archive?
        raise PackagingError.new("Multiple local paths must be packaged in an archive, not a compressed file.") if     local_paths.size > 1             && !potential_package.is_archive?
        @archive = potential_package
      end

      # Return the summarizer responsible for summarizing data on this
      # upload.
      #
      # @return [IMW::Tools::Summarizer]
      def summarizer
        @summarizer ||= IMW::Tools::Summarizer.new(local_paths)
      end

      # Set the data format to annotate the upload with.
      #
      # If not provided, Chimps will use the Infinite Monkeywrench
      # (IMW) to try and guess the data format.  See
      # IMW::Tools::Summarizer for more information.
      def fmt= new_fmt=nil
        @fmt ||= new_fmt || summarizer.most_common_data_format
      end

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

      # Use <tt>zip</tt> if the data is less than 500 MB in size and
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
      def input_paths
        raise PackaginError.new("Must specify some local paths to package") if local_paths.blank?
        local_paths + [readme_url, icss_url]
      end
      
      # The path on Infochimps to submit upload token requests to.
      #
      # @return [String]
      def token_path
        "/datasets/#{dataset}/packages/new.json"
      end

      # The path on Infochimps to submit package creation requests to.
      #
      # @return [String]
      def package_creation_path
        "/datasets/#{dataset}/packages.json"
      end

      # Return a hash of params for obtaining a new upload token.
      #
      # @return [Hash]
      def package_params
        { :package => { :fmt => fmt, :pkg_fmt => archive.extension } }
      end

      # Authorize the Chimps user for this upload.
      def authorize_for_upload!
        # FIXME we're actually just making a token request here...
        ask_for_token!
      end

      # Obtain an upload token from Infochimps.
      def ask_for_token!
        new_token = Request.new(token_path, :params => package_params, :signed => true).get
        if new_token.error?
          new_token.print
          raise AuthenticationError.new("Unauthorized for an upload token for dataset #{dataset}")
        else
          @token = new_token
        end
      end
      
      # Build the local archive if necessary.
      #
      # Will not build the local archive if there was only one local
      # input path and it was already compressed or an archive.
      def create_archive!
        return if skip_packaging?
        archiver = IMW::Tools::Archiver.new(archive.name, input_paths)
        result   = archiver.package(archive.path)
        raise PackagingError.new("Unable to package files for upload.  Temporary files left in #{archiver.tmp_dir}") if result.is_a?(StandardError) || (!archiver.success?)
        archiver.clean!
      end

      # Return a string built from the granted upload token that can
      # be fed to +curl+ in order to authenticate with and upload to
      # Amazon.
      #
      # @return [String]
      def upload_data
        data = ['AWSAccessKeyId', 'acl', 'key', 'policy', 'success_action_status', 'signature'].map { |param| "-F #{param}='#{token[param]}'" }
        data << ["-F file=@#{archive.path}"]
        data.join(' ')
      end

      # Upload the data.
      #
      # Uses +curl+ for the transfer.
      def upload!
        progress_meter = Chimps.verbose? ? '' : '-s -S'
        command = "#{curl} #{progress_meter} -o /dev/null -X POST #{upload_data} #{token['url']}"
        raise UploadError.new("Failed to upload #{archive.path} to Infochimps") unless IMW.system(command)
      end

      # Return a hash of parameters used to create a new Package at
      # Infochimps corresonding to the upload.
      #
      # @return [Hash]
      def package_data
        { :package => {:path => token['key'], :fmt => token['fmt'], :pkg_size => archive.size, :pkg_fmt => archive.extension, :summary => summarizer.summary, :token_timestamp => token['timestamp'] } }
      end

      # Make a final POST request to Infochimps, creating the final
      # resource.
      def notify_infochimps!
        package_creation_response = Request.new(package_creation_path, :signed => true, :data => package_data).post
        package_creation_response.print
        raise UploadError.new("Unable to notify Infochimps of newly uploaded data.") if package_creation_response.error?
      end

      protected
      # Require IMW and match the IMW logger to the Chimps logger.
      def require_imw
        begin
          require 'imw'
        rescue LoadError
          raise Chimps::Error.new("The Infinite Monkeywrench (IMW) gem is required to upload.")
        end
        IMW.verbose = Chimps.verbose?
      end
      
    end
  end
end
