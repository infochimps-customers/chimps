require 'chimps/utils'

module Chimps

  # Defines methods for choosing which Chimps::Command class should be
  # instantiated from the ARGV passed in on the command line.
  module CLI

    # Execute the Chimps command specified by +argv+.
    #
    # @param [Array<String>] argv
    def self.execute! argv
      begin
        Runner.new(argv).execute!    
      rescue Chimps::Error => e
        puts e.message
        exit 1
      rescue => e
        $stderr.puts("#{e.message} (#{e.class})")
        $stderr.puts(e.backtrace.join("\n"))
        exit 1
      end
    end

    # Defines methods to parse the original ARGV and from it choose
    # and instantiate the appropriate Chimps::Command subclass with
    # the appropriate arguments.
    class Runner
      include Chimps::Commands

      # The original ARGV passed in by the user.
      attr_reader :argv

      # Create a new Chimps::CLI::Runner from +argv+.
      #
      # @param [Array<String>] argv
      # @return [Chimps::CLI::Runner]
      def initialize argv
        @argv = argv
      end

      # Execute this Runner's chosen and initialized command.
      def execute!
        command.execute!
      end

      # The chosen and initialized command for this Runner.
      #
      # @return [Chimps::Command]
      def command
        @command ||= construct(command_name, argv_for_command)
      end

      protected

      # Return the index in ARGV of the command name to run.
      #
      # It may not always be the first element of ARGV because
      #
      #   chimps show my-dataset
      #   chimps -v show my-dataset
      #   chimps show -v my-dataset
      #
      # should all have the same behavior.
      #
      # @return [Integer] the index in ARGV of the command name.
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

      # The name of the command to run.
      #
      # @return [String]
      def command_name
        @command_name ||= argv[command_index]
      end

      # The ARGV to pass to the command chosen to run.
      #
      # It differs from the original ARGV only in that the command's
      # name has been stripped:
      #
      #   Chimps::CLI::Runner.new('show', '-v', 'my-dataset').argv_for_command
      #   => ['-v','my-dataset']
      #
      # This does not always return "all but the first element" of
      # ARGV; see Chimps::CLI::Runner#command_index for details.
      def argv_for_command
        returning(argv.dup) do |new_argv|
          new_argv.delete_at(command_index)
        end
      end
    end

  end
end

