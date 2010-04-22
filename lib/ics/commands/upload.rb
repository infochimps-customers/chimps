require 'ics/commands/base'

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

      attr_reader :user_defined_archive_path, :token, :archive

      def execute!
        authorize_for_upload!
        create_archive!
        ask_for_token!
        upload!
        notify_infochimps!
      end

      #
      # Parse the command line
      # 

      def dataset_identifier
        raise CLIError.new("Must provide an ID or URL-escaped handle as the first argument") if argv.first.blank?
        argv.first
      end

      def define_upload_options
        on_tail("-a", "--archive-path", "Path to the archive to be created.  Defaults to ics_ID_OR_HANDLE-DATE.zip") do |path|
          @user_defined_archive_path = path
        end

        on_tail("-c", "--curl", "Use curl instead of Ruby to transfer file (faster)") do |c|
          @curl = c
        end
      end

      #
      # Various paths
      #

      def readme_path
        File.join(ICS::CONFIG[:host], "/README-infochimps")
      end

      def icss_path
        File.join(ICS::CONFIG[:host], "datasets", dataset_identifier + ".yaml")
      end

      def input_paths
        raise CLIError.new("Must provide some paths to upload") if argv.length < 2
        argv[1..-1] + [readme_path, icss_path]
      end

      def default_archive_path
        # in current working directory...
        "ics_#{dataset_identifier}-#{Time.now.strftime(ICS::CONFIG[:timestamp_format])}.zip"
      end

      def archive_path
        @archive_path ||= File.expand_path(@user_defined_archive_path || default_archive_path)
      end

      def archive_name
        basename = File.basename(archive_path)
        return $1 if basename =~ /^(.+)\.tar\.bz2$/ || basename =~ /^(.*)\.tar\.gz$/
        return $1 if basename =~ /^(.+)\.zip/
        raise CLIError.new("Invalid archive path #{archive_path}.  Must be a .zip, .tar.bz2, or .tar.gz file.")
      end

      def archive_format
        basename = File.basename(archive_path)
        return $1 if basename =~ /\.(tar\.bz2)$/
        return $1 if basename =~ /\.(tar\.gz)$/
        return $1 if basename =~ /\.(zip)$/
        raise CLIError.new("Invalid archive path #{archive_path}.  Must be a .zip, .tar.bz2, or .tar.gz file.")
      end

      def token_path
        "/datasets/#{dataset_identifier}/packages/new.json"
      end

      def package_post_path
        "/datasets/#{dataset_identifier}/packages.json"
      end
      #
      # Workflow
      #

      def authorize_for_upload!
        # FIXME we're actually just making a token request here...
        raise AuthenticationError.new("Not authorized to upload data for dataset #{dataset_identifier}") if Request.new(token_path, :signed => true).get.error?
      end

      def archiver
        require 'imw'        
        @archiver ||= IMW::Packagers::Archiver.new(archive_name, input_paths)
      end

      def create_archive!
        puts "Creating archive..." if ICS.verbose?
        @archive = archiver.package!(archive_path)
        raise PackagingError.new("Unable to package files for upload.  Temporary files left in #{archiver.tmp_dir}") if archive.is_a?(RuntimeError) || (not archiver.success?)
        puts "Created archive at #{archive.path}"
        puts "Removing temporary files from #{archiver.tmp_dir}..." if ICS.verbose?
        archiver.clean!
      end
      
      def ask_for_token!
        @token = Request.new(token_path, :params => { 'package_format[pkg_fmt]' => archive_format }, :signed => true).get
        raise AuthenticationError.new("Unable to secure upload token from Infochimps") if @token.error?
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

      def curl
        `which curl`.chomp
      end

      def curl?
        @curl
      end
      
      def upload!
        curl? ? upload_with_curl! : upload_with_rest_client!
      end

      def upload_with_curl!
        progress_meter = ICS.verbose? ? '' : '-s -S'
        command = "#{curl} #{progress_meter} -o /dev/null -X POST #{token_data_for_curl} #{token['url']}"
        puts command if ICS.verbose?
        puts "Uploading #{archive_path} to Infochimps"
        raise ServerError.new("Failed to upload #{archive_path} to Infochimps") unless system(command)
      end

      def upload_with_rest_client!
        puts "Uploading #{archive_path}..."
        puts "POST #{token['url']}"         
        puts "token_data: #{token_data_for_rest_client.inspect}"
        begin
          # Use RestClient directly as we're talking to AWS and
          # they'll return some weird XML instead of the nice JSON
          # which comes back from ICS
          @upload_response = RestClient.post(token['url'], token_data_for_rest_client, :multipart => true, :content_type => 'multipart/form-data')
  
          
        rescue RestClient::Exception => e
          puts "#{e.http_code} -- #{e.message}"
          puts e.http_body unless e.http_body.blank?
          raise ServerError.new("Failed to upload #{archive_path} to Infochimps") if @upload_response.code !~ /201/
        end
      end

      def package_params
        { :package => {:host => 's3', :path => token['key'], :fmt => token['fmt'], :archive => archive.extname, :pkg_size => archive.size} }
      end

      def notify_infochimps!
        @package_post_response = Request.new(package_post_path, :signed => true, :data => package_params).post
        @package_post_response.print
      end

    end
  end
end

