module Chimps

  # The Chimps logger.  Set via Chimps::CONFIG[:log_file] and defaults
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
      returning(Logger.new(log_file)) do |log|
        log.progname = "Chimps"
        log.level    = Chimps.verbose? ? Logger::INFO : Logger::WARN
      end
    end

    protected
    # Return either the path to the log file in
    # Chimps::CONFIG[:log_file] or $stdout if the path is blank or
    # equal to `-'.
    #
    # @return [String, $stdout] the path to the log or $stdout
    def self.log_file
      if Chimps::CONFIG[:log_file]
        Chimps::CONFIG[:log_file].strip == '-' ? $stdout : Chimps::CONFIG[:log_file]
      else
        $stdout
      end
    end
  end
end

    
