require 'rubygems'
ENV["BUNDLE_GEMFILE"] ||= File.expand_path('../Gemfile', File.dirname(__FILE__))
require 'bundler/setup'
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
    config.resolve!
    config[:dataset] = config[:site] if (! config[:dataset]) && config[:site] # backwards compatibility
    true
  end
  
end
