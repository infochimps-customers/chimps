require 'ics/commands/base'

module ICS
  module Commands
    class Help < ICS::Command

      BANNER = "usage: ics help [COMMAND]"
      HELP = <<EOF

This is the Infochimps command-line client.  You can use it to search,
browse, create, edit, or delete data and metadata in the Infochimps
repository at http://infochimps.org.

Before you can create, edit, or delete anything you'll need to get an
Infochimps account and sign up for an API key:

  http://infochimps.org/signup

But you can still browse, search, and download (free) data
immediately.

Learn more about the Infochimps API which powers this tool at

  http://infochimps.org/api

Here's a quick summary of the available commands:

  ics search QUERY
  ics browse MODEL IDENTIFIER
  ics create PATH
  ics edit MODEL IDENTIFIER PROPERTY VALUE
  ics delete MODEL IDENTIFIER
  ics upload IDENTIFIER PATH [PATH...]
  ics help [COMMAND]

If you're confused, running `ics help' right now might be a good thing
to do!

Some general options are accepted by all the commands understood by
this program:
EOF
      
      def execute!
        if argv.first.blank?
          puts self
        else
          puts ICS::Commands.construct(argv.first, [])
        end
      end

    end
  end
end

