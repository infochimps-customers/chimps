module Chimps

  # Defines methods for choosing which Chimps::Command class should be
  # instantiated from the ARGV passed in on the command line.
  module CLI

    include Chimps::Commands

    # Execute the Chimps command specified on the command line.
    #
    # Will exit the Ruby process with 0 on success or 1 on an error.
    def self.execute!
      begin
        Chimps.boot!
        command.execute!
        return 0
      rescue Chimps::Error, Configliere::Error => e
        puts e.message
        return 1
      rescue => e
        $stderr.puts("#{e.message} (#{e.class})")
        $stderr.puts(e.backtrace.join("\n"))
        return 2
      end
    end
  end
end

