require 'chimps/config'
require 'chimps/error'

module Chimps

  module Utils
    autoload :UsesCurl,   'chimps/utils/uses_curl'
    autoload :Typewriter, 'chimps/utils/typewriter'
  end

  # The Chimps logger.  Set via Chimps.config[:log] and defaults
  # to $stdout.
  #
  # @return [Logger]
  def self.log
    @log ||= Log.new_logger
  end

  # Set the Chimps logger.
  #
  # @param [Logger] new_log
  def self.log= new_log
    @log = new_log
  end

  # Module for initializing the Chimps logger from configuration
  # settings.
  module Log

    # Initialize a new Logger instance with the log level set by
    # Chimps.verbose?
    #
    # @return [Logger]
    def self.new_logger
      require 'logger'
      Logger.new(log_file).tap do |log|
        log.progname = "Chimps"
        log.level    = Chimps.verbose? ? Logger::INFO : Logger::WARN
      end
    end

    # Return either the path to the log file in Chimps.config[:log]
    # or $stdout if the path is blank or equal to `-'.
    #
    # @return [String, $stdout] the path to the log or $stdout
    def self.log_file
      if Chimps.config[:log]
        Chimps.config[:log].strip == '-' ? $stdout : Chimps.config[:log]
      else
        $stdout
      end
    end
  end
end

    
