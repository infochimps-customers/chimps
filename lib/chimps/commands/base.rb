module Chimps

  # A base class from which to subclass specific commands.  A subclass
  # should
  #
  # - define class constants <tt>BANNER</tt> and <tt>HELP</tt> which
  # - will display the appropriate help to the user.
  # 
  # - add specific options by defining a method that begins with
  #   +define+ and ends with +options+ (i.e. - +define_output_options+
  #   to add options related to output).
  #
  # - define a method <tt>execute!</tt> which will actually run the
  #   command.
  class Command

    # Appears when printing help for this command, as the very first
    # line.  Should be one-line summary of how to use this command.
    USAGE = "Define #{self}::USAGE when you subclass Chimps::Command"

    # Appears when printing help for this command.  Should consist of
    # general help or examples of the command iteslf.  Help on
    # specific options is automatically generated.
    HELP   = "Define #{self}::HELP when you subclass Chimps::Command"

    # The configuration settings for this command.
    #
    # @return [Configliere::Param]
    attr_accessor :config

    # Create a new command.  Will define options specific to
    # subclases, parse the given +argv+, and load the global Chimps
    # configuration.  Will _not_ execute the command.
    #
    # @param  [Configliere::Param]
    # @return [Chimps::Command]
    def initialize config
      self.config = config
    end

    # The name of this command, including the
    # <tt>Chimps::Commands</tt> prefix.
    #
    # @return [String]
    def self.name
      self.to_s.downcase
    end

    # The name of this command, excluding the
    # <tt>Chimps::Commands</tt> prefix.
    #
    # @return [String]
    def name
      self.class.name.split('::').last
    end
    
    # Run this command.
    #
    # Will raise a NotImplementedError for Chimps::Command itself --
    # subclasses are expected to redefine this method.
    def execute!
      raise NotImplementedError.new("Redefine the `execute!' method in a subclass of #{self.class}.")
    end
  end
end
