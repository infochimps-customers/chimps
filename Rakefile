require 'rubygems'
require 'rake'

begin
  # http://github.com/technicalpickles/jeweler
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "chimps"
    gem.summary = "Chimps! is a Ruby wrapper and command-line interface for the Infochimps APIs (http://infochimps.org/api, http://api.infochimps.com)"
    gem.description = "Chimps! allows you to easily make API calls against Infochimps web services.  Chimps!'s Request and Response classes take care of all the details so you can remain calm and RESTful.  Chimps! also comes with a command-line tool to make it simple to query, create, update, upload, and download data on Infochimps"
    gem.email = "coders@infochimps.org"
    gem.homepage = "http://github.com/infochimps/chimps"
    gem.authors = ["Dhruv Bansal"]
    gem.add_dependency 'rest-client', ['>= 1.5.1']
    gem.add_dependency 'json',        ['>= 1.4.3']
    gem.add_dependency 'imw',         ['>= 0.2.3']
    gem.add_development_dependency "rspec", [">= 1.2.9"]
    gem.add_development_dependency "yard",  [">= 0"]
    gem.files.exclude "old/**/*"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available.  Install it with: sudo gem install jeweler"
end

desc "Build tags"
task :tags do
  system "etags -R README.rdoc bin examples lib spec"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies
task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  desc "Build YARD documentation"
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
