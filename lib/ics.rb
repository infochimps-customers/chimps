require 'rubygems'

# The ICS module implements a Ruby-based command-line interface to the
# Infochimps data repository.
#
# Using this tool you can search, download, edit, and upload data to
# and from Infochimps.
module ICS

  autoload :CONFIG,    'ics/config'
  autoload :CLI,       'ics/cli'
  autoload :Commands,  'ics/commands'
  autoload :Request,   'ics/request'
  
end
