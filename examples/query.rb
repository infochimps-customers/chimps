# This file has some examples that show you how to use Chimps to
# access the Infochimps Query API.
#
# For these exmaples to work you'll need to have signed up for an
# account on Infochimps
#
#   http://www.infochimps.com/signup
#
# and obtain your Query API key from your profile
#
#   http://www.infochimps.com/me

require 'rubygems'
$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
require 'chimps'

# Assuming you've properly set up your ~/.chimps configuration file
# (see the README), have Chimps read it by running:
Chimps.boot!

# Alternatively, you can just directly specify your key and skip the
# boot with
#
#   Chimps.config[:query][:key] = "YOUR QUERY API KEY"

# Say we to sort our friends by their Infochimps TrstRank score.  The
# TrstRank dataset we're querying is available at
#
#   http://www.infochimps.com/datasets/twitter-census-trst-rank

# First lets find our friends.
screen_names = File.read(File.dirname(__FILE__) + '/twitter_screen_names.txt').split("\n")
puts "Going to sort these Twitter users by TrstRank:"
screen_names.each { |screen_name| puts "  " + screen_name }

# Now we make a TrstRank Query API request for each of them.
trstranks = {}
puts "\nMaking requests"
screen_names.each do |screen_name|
  request = Chimps::QueryRequest.new("/soc/net/tw/trstrank", :query_params => { :screen_name => screen_name })

  # We can see the signed URL for each request
  puts request.url_with_query_string

  # And now let's run the request
  response = request.get

  # We can print the raw body
  puts response.body

  # But we can also parse the response to extract its content.
  response.parse

  trstranks[screen_name] = response['trstrank']
end

# Now let's sort our friends by TrstRank and print them out.
puts "\nSorted by TrstRank"
trstranks.sort { |a,b| a[1] <=> b[1] }.each do |screen_name, trstrank|
  puts "  #{screen_name}: #{trstrank}"
end

  


