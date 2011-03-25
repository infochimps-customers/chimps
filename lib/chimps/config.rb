require 'configliere'

module Chimps

  # Chimps configuration.  Managed by
  # Configliere[http://github.com/infochimps/configliere]
  #
  # @return [Configliere::Param]
  def self.config
    @config ||= Configliere.new
  end

  # Backwards compatibility for version < 0.3.0.
  Config = config
  
  def self.define_config
    config.define :site_config,      :description => "Path to site-wide configuration file", :env_var => "CHIMPS_ETC", :default => "/etc/chimps/chimps.yaml", :type => String, :no_help => true
    config.define :config,           :description => "Path to user configuration file", :env_var => "CHIMPS_RC", :default => (ENV["HOME"] && File.expand_path("~/.chimps")), :flag => :c, :type => String
    config.define :log,              :description => "Path to log file", :flag => :l, :type => String
    config.define :timestamp_format, :description => "Format for timestamps", :type => String, :no_help => true, :default => "%Y%m%d-%H%M%S"
    config.define :plugin_dirs,      :description => "List of directories from which to load plugins", :type => Array, :no_help => true, :default => ['/usr/share/chimps', '/usr/local/share/chimps']
    config.define :skip_plugins,     :description => "Don't load any plugins", :flag => :q, :type => :boolean
    config.define :verbose,          :description => "Be verbose", :flag => :v, :type => :boolean
    
    config.define 'query.host',      :description => "Host to send Query API requests to", :type => String, :default => "http://api.infochimps.com", :no_help => true, :env_var => "APEYEYE", :no_help => true
    config.define 'query.key',       :description => "API key for the Query API", :type => String, :no_help => true
    
    config.define 'dataset.username',   :description => "Your Infochimps username", :type => String
    config.define 'dataset.host',       :description => "Host to send Dataset API requests to", :type => String, :default => "http://www.infochimps.com", :env_var => "GEORGE", :no_help => true
    config.define 'dataset.key',        :description => "API key for the Dataset API", :type => String
    config.define 'dataset.secret',     :description => "API secret for the Dataset API", :type => String
  end
  define_config

  # Is Chimps in verbose mode?
  #
  # @return [true, false, nil]
  def self.verbose?
    config[:verbose]
  end

  # The username Chimps will pass to Infochimps.
  #
  # @return [String]
  def self.username
    config[:dataset][:username] or raise AuthenticationError.new("No Dataset API username set in #{Chimps.config[:config]} or #{Chimps.config[:site_config]}")
  end

  # The current Chimps library version.
  #
  # @return [String]
  def self.version
    return @version if @version
    version_path = File.join(File.dirname(__FILE__), '../../VERSION')
    @version ||= File.exist?(version_path) && File.new(version_path).read
  end

  # Require all Ruby files in the directory
  # Chimps.config[:plugin_dirs].
  def self.load_plugins
    return if Chimps.config[:skip_plugins]
    plugin_dirs = Chimps.config[:plugin_dirs]
    plugin_dirs.each do |dir|
      Dir[File.expand_path(dir) + "/*.rb"].each { |plugin| require plugin }
    end
  end

end
