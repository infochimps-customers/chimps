require 'optparse'
require 'chimps'
require 'chimps/utils'

module Chimps
  module CLI

    def self.execute! argv
      begin
        Runner.new(argv).execute!    
      rescue ChimpsError => e
        puts e.message
        exit 1
      rescue => e
        $stderr.puts("#{e.message} (#{e.class})")
        $stderr.puts(e.backtrace.join("\n"))
        exit 1
      end
    end
    
    class Runner
      include Chimps::Commands

      attr_reader :argv

      def initialize argv
        @argv = argv
      end

      def execute!
        command.execute!
      end
      
      def command
        @command ||= construct(command_name, argv_for_command)
      end

      protected
      def command_index
        return @command_index if @command_index
        argv.each_with_index do |arg, index|
          if command_name?(arg)
            @command_index = index
            break
          end
        end
        @command_index or raise CLIError.new("Must specify a command.  Try running `chimps help'")
      end

      def command_name
        @command_name ||= argv[command_index]
      end

      def argv_for_command
        returning(argv.dup) do |new_argv|
          new_argv.delete_at(command_index)
        end
      end
    end

  end
end

