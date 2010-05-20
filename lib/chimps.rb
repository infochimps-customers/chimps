require 'rubygems'
require 'chimps/utils'

# The Chimps module implements a Ruby-based command-line interface to
# the Infochimps data repository.
#
# Using this tool you can search, download, edit, and upload data and
# metadata to and from Infochimps.
module Chimps

  autoload :Config,     'chimps/config'
  autoload :CONFIG,     'chimps/config'
  autoload :CLI,        'chimps/cli'
  autoload :Command,    'chimps/commands/base'
  autoload :Commands,   'chimps/commands'
  autoload :Request,    'chimps/request'
  autoload :Response,   'chimps/response'
  autoload :Typewriter, 'chimps/typewriter'
  autoload :Workflows,  'chimps/workflows'
  
end
