# Chimps needs a little configuring to enable authentication with
# Infochimps.  If you have a ~/.chimps file then you can make Chimps
# read it like this:
Chimps.boot!

# You could also explicitly set the minimum required configuration
# directly:
#
#   Chimps.config[:catalog][:key]    = "YOUR CATALOG API KEY"
#   Chimps.config[:catalog][:secret] = "YOUR CATALOG API SECRET"
#   Chimps.config[:query][:key]      = "YOUR QUERY API KEY"
