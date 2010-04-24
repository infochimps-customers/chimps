module ICS
  class Command < OptionParser

    BANNER = "Define #{self}::BANNER when you subclass ICS::Command"
    HELP   = "Define #{self}::HELP when you subclass ICS::Command"

    attr_reader :argv

    def initialize argv
      super self.class::BANNER
      @argv = argv
      run_options_definers
      parse_command_line!
      ICS::Config.load
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
        raise CLIError.new("#{e.message}.  Try `ics help #{name}'")
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
        ICS::CONFIG[:verbose] = v
      end
      
      on("-i", "--identity-file PATH", "Use the given YAML identify file to authenticate with Infochimps instead of the default (~/.ics) ") do |i|
        puts "saw identify file flag, ICS::CONFIG = #{ICS::CONFIG.inspect}"
        ICS::CONFIG[:identify_file] = File.expand_path(i)
        puts "and now ICS::CONFIG = #{ICS::CONFIG.inspect}"
      end
    end
    
  end
end
