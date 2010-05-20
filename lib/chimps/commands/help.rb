module Chimps
  module Commands
    class Help < Chimps::Command

      BANNER = "usage: chimps help [COMMAND]"
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

= Commands

chimps is a wrapper over the RESTful Infochimps API.  It exposes the
following actions

  chimps list
  chimps show
  chimps create
  chimps update
  chimps destroy

for datasets (as well as other selected resources).  It also helps
automate the workflow of uploading and downloading data and making
batch changes with

  chimps upload
  chimps download
  chimps batch

You can also make queries against the Infochimps paid query API with

  chimps query

Finally, you can test that your system is configured properly and that
you can authenticate with Infochimps with

  chimps test

If you're confused try running

  chimps help COMMAND

for any of the commands above.

= Setup

Once you have obtained an API key and secret from Infochimps, place them
in a file Chimps::CONFIG[:identity_file] in your home directory with the
following format

  ---
  # API credentials for use on the main Infochimps site
  :site:
    :username: your_site_name
    :key: oreeph6giedaeL3
    :secret: Queechei6cu8chiuyiig8cheg5Ahx0boolaizi1ohtarooFu1doo5ohj5ohp9eehae5hakoongahghohgoi7yeihohx1eidaeng0eaveefohchoh6WeeV1EM

  # API credentials for use on the Infochimps paid query API
  :query:
    :username: your_query_name
    :key: zei7eeloShoah3Ce
    :secret: eixairaichaxaaRe8eeya5moh8Uthahf0pi4eig7SoirohPhei6sai8aereu0yuepiefeipoozoegahchaeheedee8uphohoo9moongae8Fa0aih4BooSeiM
EOF
      
      def execute!
        if argv.first.blank?
          puts self
        else
          puts Chimps::Commands.construct(argv.first, [])
        end
      end

    end
  end
end

