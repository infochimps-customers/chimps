require 'rubygems'
require 'chimps/config'
require 'chimps/utils'

# The Chimps module provides classes which make making requests at
# Infochimps easy.
#
# Using this tool you can search, download, edit, and upload data and
# metadata to and from Infochimps.
module Chimps

  autoload :Request,      'chimps/request'
  autoload :QueryRequest, 'chimps/query_request'  
  autoload :Response,     'chimps/response'
  autoload :Download,     'chimps/workflows/download'
  autoload :Upload,       'chimps/workflows/upload'

  # Load and resolve configuration.
  def self.boot!
    config.read config[:site_config] if config[:site_config] && File.exist?(config[:site_config])
    config.read config[:config]      if config[:config]      && File.exist?(config[:config])
    config[:catalog] = config[:site]    if (! config[:catalog]) && config[:site]    # backwards compatibility
    config[:catalog] = config[:dataset] if (! config[:catalog]) && config[:dataset] # backwards compatibility
    config.resolve!
    true
  end
  
end
