module Chimps
  class Command < OptionParser

    BANNER = "Define #{self}::BANNER when you subclass Chimps::Command"
    HELP   = "Define #{self}::HELP when you subclass Chimps::Command"

    attr_reader :argv

    def initialize argv
      super self.class::BANNER
      @argv = argv
      run_options_definers
      parse_command_line!
      Chimps::Config.load
    end

    def self.name
      self.to_s.downcase
    end

    def name
      self.class.name.split('::').last
    end
    
    protected
    def parse_command_line!
      begin
        parse!(argv)
      rescue OptionParser::InvalidOption => e
        raise CLIError.new("#{e.message}.  Try `chimps help #{name}'")
      end
    end
      
    # FIXME there's a better way to do this...
    def run_options_definers
      methods.grep(/^define.+options?$/).each { |method| send method }
    end

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
    
  end
end
