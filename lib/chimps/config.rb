module Chimps

  # Default configuration for Chimps.  User-specific configuration
  # usually lives in a YAML file <tt>~/.chimps</tt>.
  CONFIG = {
    :query => {
      :host => 'http://api.infochimps.com'
    },
    :site => {
      :host => 'http://infochimps.org'
    },
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
    CONFIG[:site][:username] or raise AuthenticationError.new("No site username set in #{Chimps::CONFIG[:identity_file]}")
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
      # FIXME this is a terrible hack...and it only goes to 2 deep!
      if File.exist?(CONFIG[:identity_file])
        require 'yaml'
        YAML.load_file(CONFIG[:identity_file]).each_pair do |key, value|
          if value.is_a?(Hash) && CONFIG.include?(key)
            CONFIG[key].merge!(value)
          else
            CONFIG[key] = value
          end
        end
      end
    end
  end
end
