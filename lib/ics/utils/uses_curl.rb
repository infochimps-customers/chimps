module ICS

  module UsesCurl

    def curl?
      @curl
    end
    
    def curl
      `which curl`.chomp
    end
    
    def define_curl_options
      on_tail("-c", "--curl", "Use curl instead of Ruby to upload package (faster)") do |c|
        @curl = c
      end
    end
    
  end
end

