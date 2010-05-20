CHIMPS_ROOT_DIR = File.join(File.expand_path(File.dirname(__FILE__)), '..') unless defined? CHIMPS_ROOT_DIR
CHIMPS_SPEC_DIR = File.join(CHIMPS_ROOT_DIR, 'spec')                        unless defined? CHIMPS_SPEC_DIR
CHIMPS_LIB_DIR  = File.join(CHIMPS_ROOT_DIR, 'lib')                         unless defined? CHIMPS_LIB_DIR
$: << CHIMPS_LIB_DIR

require 'rubygems'
require 'spec'
require 'chimps'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |path| require path }

Spec::Runner.configure do |config|
  config.include Chimps::Test::CustomMatchers
end

  

