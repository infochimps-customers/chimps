module Chimps

  # A module defining classes to handle complex workflows between the
  # local machine and Infochimps' servers.
  module Workflows
    autoload :Upload,       'chimps/workflows/up'
    autoload :Up,           'chimps/workflows/up'
    autoload :Downloader,   'chimps/workflows/downloader'
    autoload :BatchUpdater, 'chimps/workflows/batch'
  end
end

