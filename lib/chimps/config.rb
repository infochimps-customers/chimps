require 'configliere'

module Chimps

  # Chimps configuration.  Managed by
  # Configliere[http://github.com/infochimps/configliere]
  Config = Configliere.new

  Config.define :site_config,      :description => "Path to site-wide configuration file", :env_var => "CHIMPS_ETC", :default => "/etc/chimps/chimpsrc.yaml", :type => String, :no_help => true
  Config.define :config,           :description => "Path to user configuration file", :env_var => "CHIMPS_RC", :default => (ENV["HOME"] && File.expand_path("~/.chimps")), :flag => :c, :type => String
  Config.define :log,              :description => "Path to log file", :flag => :l, :type => String
  Config.define :timestamp_format, :description => "Format for timestamps", :type => String, :no_help => true, :default => "%Y%m%d-%H%M%S"
  Config.define :plugin_dirs,      :description => "List of directories from which to load plugins", :type => Array, :no_help => true, :default => ['/usr/share/chimps', '/usr/local/share/chimps']
  Config.define :skip_plugins,     :description => "Don't load any plugins", :flag => :q, :type => :boolean
  Config.define :verbose,          :description => "Be verbose", :flag => :v, :type => :boolean
   
  Config.define 'query.host',      :description => "Host to send Query API requests to", :type => String, :default => "http://api.infochimps.com", :no_help => true, :env_var => "CHIMPS_QUERY_HOST"
  Config.define 'query.key',       :description => "API key for the Query API", :type => String, :no_help => true
  
  Config.define 'site.username',   :description => "Your Infochimps username", :type => String
  Config.define 'site.host',       :description => "Host to send Dataset API requests to", :type => String, :default => "http://infochimps.org", :env_var => "CHIMPS_DATASET_HOST"
  Config.define 'site.key',        :description => "API key for the Dataset API", :type => String
  Config.define 'site.secret',     :description => "API secret for the Dataset API", :type => String

  # Is Chimps in verbose mode?
  #
  # @return [true, false, nil]
  def self.verbose?
    Config[:verbose]
  end

  # The username Chimps will pass to Infochimps.
  #
  # @return [String]
  def self.username
    Config[:site][:username] or raise AuthenticationError.new("No Dataset API username set in #{Chimps::Config[:config]} or #{Chimps::Config[:site_config]}")
  end

  def self.version
    version_path = File.join(File.dirname(__FILE__), '../../VERSION')
    @version ||= File.exist?(version_path) && File.new(version_path).read
  end

  # Require all Ruby files in the directory
  # Chimps::Config[:plugin_dirs].
  def self.load_plugins
    return if Chimps::Config[:skip_plugins]
    plugin_dirs = Chimps::Config[:plugin_dirs]
    plugin_dirs.each do |dir|
      Dir[File.expand_path(dir) + "/*.rb"].each { |plugin| require plugin }
    end
  end

end
