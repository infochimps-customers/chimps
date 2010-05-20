require 'optparse'

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
  class Command < OptionParser

    # Appears when printing help for this command, as the very first
    # line.  Should be one-line summary of how to use this command.
    BANNER = "Define #{self}::BANNER when you subclass Chimps::Command"

    # Appears when printing help for this command.  Should consist of
    # general help or examples of the command iteslf.  Help on
    # specific options is automatcally generated.
    HELP   = "Define #{self}::HELP when you subclass Chimps::Command"

    # The (processed) ARGV for this command.
    attr_reader :argv

    # Create a new command.  Will define options specific to
    # subclases, parse the given +argv+, and load the global Chimps
    # configuration.  Will _not_ execute the command.
    #
    # @param [Array<String>] argv
    # @return [Chimps::Command]
    def initialize argv
      super self.class::BANNER
      @argv = argv
      run_options_definers
      parse_command_line!
      Chimps::Config.load
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
    
    protected
    
    # Parse the command line.
    def parse_command_line!
      begin
        parse!(argv)
      rescue OptionParser::InvalidOption => e
        raise CLIError.new("#{e.message}.  Try `chimps help #{name}'")
      end
    end
      
    # Run all methods beginning with +define+ and ending with +option+
    # or +options+.
    #
    # This is (hackish) mechanism for subclasses of Chimps::Command to
    # define their own specific options.
    def run_options_definers
      # FIXME there's a better way to do this...      
      methods.grep(/^define.+options?$/).each { |method| send method }
    end

    # Define options common to all Chimps' commands.  The two only two
    # such options at the moment are <tt>-v</tt> (or
    # <tt>--[no-]verbose</tt>) for verbosity, and <tt>-i</tt> (or
    # <tt>--identity-file</tt>) for setting the identify file to use.
    def define_common_options
      separator self.class::HELP
      separator "\nOptions include:"
      
      on("-v", "--[no-]verbose", "Be verbose, or not.") do |v|
        Chimps::CONFIG[:verbose] = v
      end
      
      on("-i", "--identity-file PATH", "Use the given YAML identify file to authenticate with Infochimps instead of the default (~/.chimps) ") do |i|
        Chimps::CONFIG[:identity_file] = File.expand_path(i)
      end
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
