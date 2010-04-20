require 'optparse'

require 'ics/utils'

module ICS
  module Commands

    def self.construct command_name, argv
      self.constants.each do |constant_name|
        return "ICS::Commands::#{constant_name}".constantize.new(argv) if constant_name.downcase == command_name
      end
      raise CLIError.new("Invalid command: #{command_name}.  Try running `ics help'")
    end

    def construct command_name, argv
      ICS::Commands.construct command_name, argv
    end
    

    NAMES = %w[search help test create show]
    
    NAMES.each do |name|
      autoload name.capitalize.to_sym, "ics/commands/#{name}"
    end
    
    def command_name? name
      NAMES.include?(name)
    end
  end
end
