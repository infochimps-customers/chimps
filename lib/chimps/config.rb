module Chimps

  # Load all configuration, load plugins, and resolve options.
  def self.boot!
    Chimps::Config.load
    Chimps::Config.load_plugins
    Chimps::Config.resolve_options!
  end

  # Options that can be overriden by the command-line.
  COMMAND_LINE_OPTIONS = {
    :identity_file    => File.expand_path(ENV["CHIMPS_RC"] || "~/.chimps"),
    # log_file -- will be specified on command line
    # verbose  -- will be specified on command line
  }

  # Default configuration for Chimps.  User-specific configuration
  # lives in a YAML file <tt>~/.chimps</tt>.
  CONFIG = {
    :query => {
      :host => ENV["CHIMPS_QUERY_HOST"] || 'http://api.infochimps.com'
    },
    :site => {
      :host => ENV["CHIMPS_HOST"]       || 'http://infochimps.org'
    },
    :timestamp_format => "%Y-%m-%d_%H-%M-%S",
    :plugins => ["/usr/local/share/chimps"]
  }

  # Is Chimps in verbose mode?
  #
  # @return [true, false, nil]
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
    
    # Ensure that certain options (verbosity, log file) that can be
    # passed on the command-line override those stored in a
    # configuration file (if present).
    def self.resolve_options!
      Chimps::CONFIG.merge!(Chimps::COMMAND_LINE_OPTIONS) # overwrites from command line if necessary
    end
    
    # The root of the Chimps source base.
    #
    # @return [String]
    def self.chimps_root
      File.expand_path File.join(File.dirname(__FILE__), '../..')
    end

    # Require all ruby files in the directory
    # Chimps::CONFIG[:plugins].
    def self.load_plugins
      return if Chimps::CONFIG[:skip_plugins]
      plugin_dirs = Chimps::CONFIG[:plugins]
      return if plugin_dirs.blank?
      plugin_dirs.each do |dir|
        Dir[File.expand_path(dir) + "/*.rb"].each { |plugin| require plugin }
      end
    end

    # Load the configuration settings from the configuration/identity
    # file.
    def self.load
      # FIXME this is a terrible hack...and it only goes to 2 deep!
      if File.exist?(COMMAND_LINE_OPTIONS[:identity_file])
        require 'yaml'
        YAML.load_file(COMMAND_LINE_OPTIONS[:identity_file]).each_pair do |key, value|
          case
          when value.is_a?(Hash) && CONFIG.include?(key)
            CONFIG[key].merge!(value)
          when value.is_a?(Array) && CONFIG.include?(key)
            CONFIG[key] += value
          else
            CONFIG[key] = value
          end
        end
      end
    end
  end
end
