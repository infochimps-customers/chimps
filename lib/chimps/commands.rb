require 'optparse'

require 'chimps/utils'

module Chimps
  module Commands

    def self.construct command_name, argv
      self.constants.each do |constant_name|
        return "Chimps::Commands::#{constant_name}".constantize.new(argv) if constant_name.downcase == command_name
      end
      raise CLIError.new("Invalid command: #{command_name}.  Try running `chimps help'")
    end

    def construct command_name, argv
      Chimps::Commands.construct command_name, argv
    end

    NAMES = %w[search help test create show update destroy upload list download batch]
    
    NAMES.each do |name|
      autoload name.capitalize.to_sym, "chimps/commands/#{name}"
    end
    
    def command_name? name
      NAMES.include?(name)
    end
  end
end
