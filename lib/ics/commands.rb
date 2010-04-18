require 'optparse'

require 'ics/utils'

module ICS
  module Commands

    def self.find command
      constants.each do |c|
        return "ICS::Commands::#{c}".constantize if c.downcase == command
      end
      raise CLI::Error.new("Invalid command: #{command}.  Try running `ics help'")
    end

    autoload :Search, 'ics/commands/search'
    autoload :Help,   'ics/commands/help'
    autoload :Test,   'ics/commands/test'
    
  end
  
end
