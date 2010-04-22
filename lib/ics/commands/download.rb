require 'ics/commands/base'

module ICS
  module Commands
    class Download < ICS::Command

      BANNER = "usage: ics download [OPTIONS] ID_OR_HANDLE"
      HELP   = <<EOF

Download a dataset identified by the given ID_OR_HANDLE to the current
directory.

EOF
      PATH = "/download_tokens"

      attr_reader :token

      def define_options
        on_tail("-o", "--output PATH", "Path to download file to") do |o|
          @output = File.expand_path(o)
        end
      end
      
      def package_id
        raise CLIError.new("Must provide an ID_OR_HANDLE of a package to download.") if argv.first.blank?
        argv.first
      end

      def token_params
        { :download_token => { :package_id => package_id } }
      end

      def execute!
        ask_for_token!
        download!
      end

      def ask_for_token!
        @token = Request.new(PATH, :data => token_params, :sign_if_possible => true).post
        if token.error?
          token.print
          exit
        end
      end

      def output
        @output || token["download_token"]["package"]["basename"]
      end

      def download_url
        token['download_token']['package']['url']
      end
      
      def download!
        download_with_curl!
      end

      def curl
        `which curl`.chomp
      end

      def download_with_curl!
        command = "#{curl} -o '#{output}' '#{download_url}'"
        puts command if ICS.verbose?
        system(command)
      end
      
    end
  end
end

