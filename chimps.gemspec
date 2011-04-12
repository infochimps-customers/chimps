# -*- encoding: utf-8 -*-
ENV['BUNDLE_GEMFILE'] = File.dirname(__FILE__) + '/Gemfile'
$:.push File.expand_path("../lib", __FILE__)
require 'bundler'
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
  s.executables      = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths    = ["lib"]
end

