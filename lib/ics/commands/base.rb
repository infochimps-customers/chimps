module ICS
  class Command < OptionParser

    # 
    # The following constants and methods should be overridden by
    # subclasses
    #

    BANNER = "Define #{self}::BANNER when you subclass ICS::Command"
    HELP   = "Define #{self}::HELP when you subclass ICS::Command"

    def define_options
      raise NotImplementedError.new("Define #{self.class}#define_options when you subclass ICS::Command.  It should call methods like OptionParser#on to define command line options for this command.")
    end


    #
    # Begin base class definition
    #
    
    attr_reader :argv

    def initialize argv
      super self.class::BANNER
      separator self.class::HELP
      @argv = argv
      define_common_options
      define_options
      parse_command_line!
      ICS::Config.load
    end

    def define_common_options
      on("-v", "--[no]-verbose", "Be verbose, or not.") do |v|
        ICS::CONFIG[:verbose] = v
      end
      
      on("-i", "--identity-file PATH", "Use the given YAML identify file to authenticate with Infochimps instead of the default (~/.ics) ") do |i|
        ICS::CONFIG[:identify_file] = File.expand_path(i)
      end
    end

    def parse_command_line!
      parse!
    end

    def emit *args
      args.each do |line|
        puts case line
             when String then line
             when Array then line.join("\t")
             when Hash then line.inspect
             end
      end
    end

  end
end
