require 'chimps/utils'

module Chimps

  # A namespace to hold the various commands Chimps defines.
  module Commands

    # Construct a new command from the given +command_name+ and +argv.
    # The resulting command will be initialized but will not have been
    # executed.
    #
    # @param [String] command_name
    # @param [Array<String>] argv
    # @return [Chimps::Command]
    def self.construct command_name, argv
      self.constants.each do |constant_name|
        return "Chimps::Commands::#{constant_name}".constantize.new(argv) if constant_name.downcase == command_name
      end
      raise CLIError.new("Invalid command: #{command_name}.  Try running `chimps help'")
    end

    # Construct a new command from the given +command_name+ and
    # +argv+.
    #
    # Delegates to Chimps::Commands.construct, so see its
    # documentation for more information.
    def construct command_name, argv
      Chimps::Commands.construct command_name, argv
    end

    # A list of all the commmand names defined by Chimps.  Each name
    # maps to a corresponding subclass of Chimps::Command living in
    # the Chimps::Commands module.
    NAMES = %w[search help test create show update destroy upload list download batch]
    
    NAMES.each do |name|
      autoload name.capitalize.to_sym, "chimps/commands/#{name}"
    end

    # Is +name+ a Chimps command name?
    #
    # @param [String] name
    # @return [true, false]
    def command_name? name
      NAMES.include?(name)
    end
  end
end
