# Here are some examples of how to search, list, and show information
# about datasets on Infochimps.
#
# All the Catalog API calls utilized in this file are documented at
#
#   http://www.infochimps.com/catalog-api
#
# None of the examples in this file require authentication with
# Infochimps so there's no need to configure Chimps in any way or to
# even have an Infochimps account.
#
# Other examples which modify data in the Infochimps Catalog will
# require you to have an Infochimps account and to properly configure
# Chimps to use it.

require 'rubygems'
$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
require 'chimps'

# Say we wanted to find a list of sources who have contributed
# downloadable music datasets to Infochimps.
#
# We'll do this by searching for datasets about 'music' and examining
# each one to find its source (there are other ways to do this ;).
#
# The first call we'll need to make is the search.  This is documented
# at
#
#   http://www.infochimps.com/catalog-api#search
request = Chimps::Request.new('/search', :query_params => { :query => 'music', :dataset_type => 'download' })

# We can see the URL that's generated for this query:
puts "URL for search of downloadable music datasets:"
puts request.url_with_query_string

# Let's run the query by sending off an HTTP GET request.
puts "\nSending GET request"
response = request.get

# The response knows about its HTTP response code and its headers
puts "\nReceived a #{response.code} response with the following headers"
p response.headers

# The response has a raw body but we can also parse it.
response.parse
puts "\nThere were #{response.size} results:"

# Lets print the titles of each of the datasets.  This works because
# we just parsed the response above.
response.each do |result|
  dataset = result['dataset']
  puts ""
  puts dataset['title']
  if dataset['sources'] && (!dataset['sources'].empty?)
    dataset['sources'].each do |source|
      puts "  Source: " + source['title']
    end
  else
    puts "  No sources."
  end
end

# Let's look a little deeper at the first result.
puts("No results!") && exit(1) if response.empty?
dataset = response.first['dataset']

# Let's get more detail about this dataset.  This uses the "Show
# Dataset" API documented at
#
#   http://www.infochimps.com/catalog-api#dataset_show
id              = dataset['cached_slug']          # we can also use ID here
dataset_request = Chimps::Request.new("/datasets/#{id}")

# Let's run this next query
puts "\n\nURL for details on dataset #{id}"
puts dataset_request.url_with_query_string
puts "\nSending GET request"
dataset_response = dataset_request.get

# Let's just print the body of the response this time.
puts ""
puts dataset_response.body
