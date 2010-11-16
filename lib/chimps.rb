require 'rubygems'
require 'bundler/setup'
require 'chimps/utils'

# The Chimps module implements a Ruby-based command-line interface to
# the Infochimps data repository.
#
# Using this tool you can search, download, edit, and upload data and
# metadata to and from Infochimps.
module Chimps

  autoload :Config,       'chimps/config'
  autoload :CLI,          'chimps/cli'
  autoload :Command,      'chimps/commands/base'
  autoload :Commands,     'chimps/commands'
  autoload :Request,      'chimps/request'
  autoload :QueryRequest, 'chimps/request'  
  autoload :Response,     'chimps/response'
  autoload :Typewriter,   'chimps/typewriter'
  autoload :Workflows,    'chimps/workflows'

  # Load and resolve configuration.
  def self.boot!
    Config.read Config[:site_config] if Config[:site_config] && File.exist?(Config[:site_config])
    Config.read Config[:config]      if Config[:config]      && File.exist?(Config[:config])
    Config.resolve!
  end
  
end
