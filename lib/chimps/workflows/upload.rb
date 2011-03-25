module Chimps

  # An upload at Infochimps is a process attached to a dataset which
  # carries a state.
  #
  # A dataset typically does not have an "upload" associated with it
  # but anyone authorized to update the dataset can *create* an upload
  # for it.  This upload object is empty by default.  You can submit
  # files or links to upload.  When you're done you can submit the
  # entire upload for processing.  You can view the status of the
  # upload at any time.
  class Upload

    # The slug or (ID) of the dataset to upload for
    attr_accessor :slug

    # Gives the ability to use curl to upload local files.
    include Chimps::Utils::UsesCurl

    # Create a new Upload for the dataset with the given +slug+ or ID.
    #
    # @return [Chimps::Upload]
    def initialize slug
      self.slug = slug
    end

    # Show this upload.
    #
    # @return [Chimps::Response]
    def show
      follow_redirects_on :get, "/datasets/#{slug}/upload.yaml"
    end

    # Create this upload on Infochimps.
    #
    # @return [Chimps::Response]
    def create
      follow_redirects_on :post, "/datasets/#{slug}/upload.json", :body => true do |response, request, result, &block|
        if response.code == 409
          response              # upload already exists
        else
          response.return!(request, result, &block)
        end
      end
    end
    
    def update params={}
      follow_redirects_on :put, "/datasets/#{slug}/upload.json", params
    end

    def upload_files *paths
      paths.map { |p| File.expand_path(p) }.each do |path|
        upload_file(upload_token)
      end
    end

    def upload_token
      follow_redirects_on :get, "/datasets/#{slug}/upload.json", :query => { :token => true }
    end

    def upload_file path, token
      token.parse
      p token
      raise UploadError.new("#{path} does not exist")                          unless File.exist?(path)
      raise UploadError.new("#{path} is a directory -- can only upload files") if File.directory?(path)
      params = %w[AWSAccessKeyId acl key policy success_action_status signature].map do |param|
        [param, token[param]]
      end
      params << ['file', '@' + path] # this is how you tell curl to upload a file
      Chimps.log.info("Uploading #{path} for dataset #{slug}")
      curl token['url'], :method => "POST", :params => params
    end

    def remove_files *uuids
      follow_redirects_on :put, "/datasets/#{slug}/upload.json", :body => { :upload => { :remove_files => uuids }}
    end

    def create_links *links
      follow_redirects_on :put, "/datasets/#{slug}/upload.json", :body => { :upload => { :add_links    => links }}
    end

    def remove_links *uuids
      follow_redirects_on :put, "/datasets/#{slug}/upload.json", :body => { :upload => { :remove_links => uuids }}
    end
    
    def start
      follow_redirects_on :put, "/datasets/#{slug}/upload.json", :query => { :submit => true }
    end
    
    def destroy
      follow_redirects_on :delete, "/datasets/#{slug}/upload.json"
    end

    def restart
      follow_redirects_on :delete, "/datasets/#{slug}/upload.json", :query => { :restart => true }
    end

    def follow_redirects_on method, url, options={}, &block
      Request.new(url, {:sign => true}.merge(options)).send(method) do |response, request, result, &block|
        if [301, 302, 307].include?(response.code)
          response.follow_redirection(request, result, &block)
        else
          if response.code != 200 && block_given?
            response.return!(request, result, &block)
          else
            response.return!(request, result)
          end
        end
      end
    end
  end
  
end
