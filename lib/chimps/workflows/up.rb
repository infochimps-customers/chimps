module Chimps
  module Workflows

    # A namespace for classes which handle each step of the
    # BundleAndUpload workflow.
    module Upload
      autoload :UploadToken, 'chimps/workflows/upload/token'
      autoload :Bundler,     'chimps/workflows/upload/bundler'
      autoload :Uploader,    'chimps/workflows/upload/uploader'
      autoload :Notifier,    'chimps/workflows/upload/notifier'
    end

    # Uploads data to Infochimps by first asking for authorization,
    # creating an archive, obtaining a token, uploading data, and
    # notifing Infochimps.
    #
    # A helper object from Chimps::Workflows::Upload is delegated to
    # for each step:
    #
    # - authorization & obtaining a token: Chimps::Workflows::Upload::UploadToken
    # - creating an archive: Chimps::Workflows::Upload::Bundler
    # - uploading data: Chimps::Workflows::Upload::Uploader
    # - notifying Infochimps: Chimps::Workflows::Upload::Notifier
    class Up

      # The ID or handle of the dataset to download.
      attr_accessor :dataset

      # An array of paths to files and directories to package into an
      # archive.
      attr_accessor :paths

      # The format to annotate the upload with.
      attr_accessor :fmt

      # The path to the archive to create when uploading.
      attr_accessor :archive

      # Create a new Uploader from the given parameters.
      #
      # If <tt>:fmt</tt> is provided it will be used as the data
      # format to annotate the upload with.  If not, Chimps will try
      # to guess.
      #
      # @param [Hash] options
      # @option options [String, Integer] dataset the ID or handle of the dataset to which data should be uploaded
      # @option options [Array<String>] paths the paths to aggregate and upload
      # @option options [String, IMW::Resource] archive (IMW::Workflows::Downloader#default_archive_path) the path to the archive to create
      # @option options [String] fmt the data format to annotate the upload with
      def initialize options={}
        self.dataset = options[:dataset] or raise PackagingError.new("Must provide the ID or handle of a dataset to upload data to.")
        self.paths   = options[:paths]
        self.archive = options[:archive]        
        self.fmt     = options[:fmt]
      end

      # Upload data to Infochimps by first asking for authorization,
      # creating an archive, obtaining a token, uploading data, and
      # notifing Infochimps.
      def execute!
        authorize_for_upload!
        bundle!
        ask_for_token!
        upload!
        notify_infochimps!
      end

      #
      # == Helper Objects ==
      #

      # The token authorizing an upload.
      #
      # @return [Chimps::Workflows::Upload::UploadToken]
      def authorization_token
        @authorization_token ||= Chimps::Workflows::Upload::UploadToken.new(dataset)
      end
      
      # The bundler that will aggregate data for the upload.
      #
      # @return [Chimps::Workflows::Upload::Bundler]
      def bundler
        @bundler ||= Chimps::Workflows::Upload::Bundler.new(dataset, paths, :fmt => fmt, :archive => archive)
      end

      # The token consumed for an upload.
      #
      # @return [Chimps::Workflows::Upload::UploadToken]
      def upload_token
        @upload_token ||= Chimps::Workflows::Upload::UploadToken.new(dataset, :fmt => bundler.fmt, :pkg_fmt => bundler.pkg_fmt)
      end
      
      # The uploader that will actually send data to Infochimps.
      #
      # @return [Chimps::Workflows::Upload::Uploader]
      def uploader
        @uploader ||= Chimps::Workflows::Upload::Uploader.new(upload_token, bundler)
      end
      
      # The notifier that will inform Infochimps of the new data.
      #
      # @return [Chimps::Workflows::Upload::Notifer]
      def notifier
        @notifier ||= Chimps::Workflows::Upload::Notifier.new(upload_token, bundler)
      end

      #
      # == Actions ==
      #
      
      # Authorize the Chimps user for this upload.
      #
      # Delegates to Chimps::Workflows::Upload::UploadToken
      def authorize_for_upload!
        authorization_token.get
      end

      # Bundle the data together.
      #
      # Delegates to Chimps::Workflows::Upload::Bundler
      def bundle!
        bundler.bundle!
      end

      # Obtain an upload token from Infochimps.
      #
      # Delegates to Chimps::Workflows::Upload::UploadToken
      def ask_for_token!
        upload_token.get
      end

      # Upload the data to Infochimps.
      #
      # Delegates to Chimps::Workflows::Upload::Uploader
      def upload!
        uploader.upload!
      end
      
      # Make a final POST request to Infochimps, creating the final
      # resource.
      #
      # @return [Chimps::Response]
      def notify_infochimps!
        notifier.post
      end
      
    end
  end
end
