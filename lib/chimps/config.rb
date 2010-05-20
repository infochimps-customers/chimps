require 'yaml'
module Chimps

  # Default configuration for Chimps.  User-specific configuration
  # usually lives in a YAML file <tt>~/.chimps</tt>.
  CONFIG = {
    :host             => ENV["CHIMPS_HOST"] || 'http://infochimps.org',
    :identity_file    => File.expand_path(ENV["CHIMPS_RC"] || "~/.chimps"),
    :verbose          => nil,
    :timestamp_format => "%Y-%m-%d_%H-%M-%S"
  }

  # Is Chimps in verbose mode?
  #
  # @return [true, false]
  def self.verbose?
    CONFIG[:verbose]
  end

  # The username Chimps will pass to Infochimps.
  #
  # @return [String]
  def self.username
    CONFIG[:username] or raise AuthenticationError.new("No username set in #{Chimps::CONFIG[:identity_file]}")
  end

  # Defines methods to load the Chimps configuration.
  module Config

    # The root of the Chimps source base.
    #
    # @return [String]
    def self.chimps_root
      File.expand_path File.join(File.dirname(__FILE__), '../..')
    end

    # Load the configuration settings from the configuration/identity
    # file.
    def self.load
      if File.exist?(CONFIG[:identity_file])
        YAML.load_file(CONFIG[:identity_file]).each do |key, value|
          CONFIG[key.to_sym] = value
        end
      end
    end
  end
end
