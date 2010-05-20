module Chimps
  module Workflows
    class Uploader

      include Chimps::Utils::UsesCurl

      attr_reader :dataset, :archive_path, :local_paths, :token, :archive

      def execute!
        authorize_for_upload!
        create_archive!
        ask_for_token!
        upload!
        notify_infochimps!
      end

      def initialize options={}
        @dataset      = options[:dataset]
        @archive_path = File.expand_path(options[:archive] || default_archive_path)
        @local_paths  = options[:local_paths]
        @curl         = options[:curl]
      end

      #
      # Paths, both local and remote
      #
      def readme_path
        File.join(Chimps::CONFIG[:host], "/README-infochimps")
      end

      def chimpss_path
        File.join(Chimps::CONFIG[:host], "datasets", "#{dataset}.yaml")
      end

      def input_paths
        raise PackaginError.new("Must specify some local paths to package") if local_paths.blank?
        local_paths + [readme_path, icss_path]
      end

      def token_path
        "/datasets/#{dataset}/packages/new.json"
      end

      def package_post_path
        "/datasets/#{dataset}/packages.json"
      end

      def default_archive_path
        # in current working directory...
        "chimps_#{dataset}-#{Time.now.strftime(Chimps::CONFIG[:timestamp_format])}.zip"
      end
      
      #
      # FIXME IMW should make these methods unnecessary
      #
      def archive_name
        basename = File.basename(archive_path)
        return $1 if basename =~ /^(.+)\.tar\.bz2$/ || basename =~ /^(.*)\.tar\.gz$/
        return $1 if basename =~ /^(.+)\.zip/
        raise PackagingError.new("Invalid archive path #{archive_path}.  Must be a .zip, .tar.bz2, or .tar.gz file.")
      end

      def archive_format
        basename = File.basename(archive_path)
        return $1 if basename =~ /\.(tar\.bz2)$/
        return $1 if basename =~ /\.(tar\.gz)$/
        return $1 if basename =~ /\.(zip)$/
        raise PackagingError.new("Invalid archive path #{archive_path}.  Must be a .zip, .tar.bz2, or .tar.gz file.")
      end

      #
      # Workflow
      #
      def authorize_for_upload!
        # FIXME we're actually just making a token request here...
        ask_for_token!
      end

      def archiver
        require 'imw'        
        @archiver ||= IMW::Tools::Archiver.new(archive_name, input_paths)
      end

      def create_archive!
        puts_and_again("Creating archive...", "done") do
          @archive = archiver.package!(archive_path)
        end
        raise PackagingError.new("Unable to package files for upload.  Temporary files left in #{archiver.tmp_dir}") if archive.is_a?(RuntimeError) || (not archiver.success?)
        puts_and_again("Removing temporary files from #{archiver.tmp_dir}...", "done") do
          archiver.clean!
        end
      end
      
      def ask_for_token!
        @token = Request.new(token_path, :signed => true).get
        if @token.error?
          @token.print if Chimps.verbose?
          raise AuthenticationError.new("Unable to secure upload token from Infochimps")
        end
      end

      def token_data_for_rest_client
        data = token.dup
        data.delete('url')
        data.delete('fmt')
        data[:file] = File.new(archive_path)
        data
      end

      def token_data_for_curl
        data = ['AWSAccessKeyId', 'acl', 'key', 'policy', 'success_action_status', 'signature'].map { |param| "-F #{param}='#{token[param]}'" }
        data << ["-F file=@#{archive_path}"]
        data.join(' ')
      end

      def upload!
        curl? ? upload_with_curl! : upload_with_rest_client!
      end

      def upload_with_curl!
        progress_meter = Chimps.verbose? ? '' : '-s -S'
        command = "#{curl} #{progress_meter} -o /dev/null -X POST #{token_data_for_curl} #{token['url']}"
        puts command if Chimps.verbose?
        puts_and_again("Uploading #{archive_path} to Infochimps...", "done") do
          raise UploadError.new("Failed to upload #{archive_path} to Infochimps") unless system(command)
        end
      end

      def upload_with_rest_client!
        puts "Uploading #{archive_path} to Infochimps..."
        puts "POST #{token['url']}"         
        puts "token_data: #{token_data_for_rest_client.inspect}"
        begin
          # Use RestClient directly as we're talking to AWS and
          # they'll return some weird XML instead of the nice JSON
          # which comes back from Chimps
          @upload_response = RestClient.post(token['url'], token_data_for_rest_client, :multipart => true, :content_type => 'multipart/form-data')
        rescue RestClient::Exception => e
          puts "#{e.http_code} -- #{e.message}"
          puts e.http_body unless e.http_body.blank?
          raise UploadError.new("Failed to upload #{archive_path} to Infochimps") if @upload_response.code !~ /201/
        end
      end

      def package_params
        { :package => {:path => token['key'], :fmt => token['fmt'], :pkg_size => archive.size} }
      end

      def notify_infochimps!
        @package_post_response = Request.new(package_post_path, :signed => true, :data => package_params).post
      end
      
    end
  end
end
