require 'yaml'
module Chimps

  # Configuration for chimps lives here.
  CONFIG = {
    :host          => ENV["Chimps_HOST"] || 'http://infochimps.org',
    :identity_file => File.expand_path("~/.chimps"),
    :verbose       => nil,
    :timestamp_format => "%Y-%m-%d_%H-%M-%S"
  }

  def self.verbose?
    CONFIG[:verbose]
  end

  def self.username
    CONFIG[:username] or raise AuthenticationError.new("No username set in #{Chimps::CONFIG[:identity_file]}")
  end

  module Config

    def self.chimps_root
      File.expand_path File.join(File.dirname(__FILE__), '../..')
    end

    def self.load
      if File.exist?(CONFIG[:identity_file])
        YAML.load_file(CONFIG[:identity_file]).each do |key, value|
          CONFIG[key.to_sym] = value
        end
      end
    end
  end
end
