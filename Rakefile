require 'rubygems'
require 'rake'

begin
  # http://github.com/technicalpickles/jeweler
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "chimps"
    gem.summary = "Chimps is a Ruby interface for the Infochimps Dataset & Query APIs (http://www.infochimps.com/api)"
    gem.description = "Chimps allows you to easily make API calls against Infochimps web services.  Chimps!'s Request and Response classes take care of all the details so you can remain calm and RESTful."
    gem.email = "coders@infochimps.com"
    gem.homepage = "http://github.com/infochimps/chimps"
    gem.authors = ["Dhruv Bansal"]
    gem.files.exclude "old/**/*"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available.  Install it with: sudo gem install jeweler"
end

desc "Build tags"
task :tags do
  system "etags -R README.rdoc examples lib spec"
end

