require 'rubygems'

# The Chimps module implements a Ruby-based command-line interface to the
# Infochimps data repository.
#
# Using this tool you can search, download, edit, and upload data to
# and from Infochimps.
module Chimps

  autoload :CONFIG,    'chimps/config'
  autoload :CLI,       'chimps/cli'
  autoload :Commands,  'chimps/commands'
  autoload :Request,   'chimps/request'
  
end
