require 'optparse'
require 'ics'
require 'ics/utils'

module ICS
  module CLI

    def self.execute! argv
      Runner.new(argv).execute!
    end
    
    class Runner
      include ICS::Commands

      attr_reader :argv

      def initialize argv
        @argv = argv
      end

      def command
        @command ||= construct(command_name, argv_for_command)
      end

      def execute!
        command.execute!
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
        @command_index or raise Error.new("Must specify a command.  Try running `ics help'")
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

