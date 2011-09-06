# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$:.unshift(lib) unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name             = "chimps"
  s.version          = File.read(File.expand_path("../VERSION", __FILE__))
  s.platform         = Gem::Platform::RUBY
  s.authors          = ["Dhruv Bansal"]
  s.email            = ["coders@infochimps.com"]
  s.homepage         = "http://github.com/infochimps/chimps"
  s.summary          = "Chimps is a Ruby interface for the Infochimps Catalog & Query APIs (http://www.infochimps.com/apis)"
  s.description      = "Chimps allows you to easily make API calls against Infochimps web services.  Chimps's Request and Response classes take care of all the details so you can remain calm and RESTful."
  s.extra_rdoc_files = ["README.rdoc"]
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- spec/*`.split("\n")
  s.require_paths    = ["lib"]
  
  s.add_dependency "json"
  s.add_dependency "configliere", "0.4.6"
  s.add_dependency "rest-client", ">= 1.6.1"
  s.add_dependency "addressable"

  s.add_development_dependency "rake", "~> 0.9.2"
  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "yard", '~> 0.7.2'
end

