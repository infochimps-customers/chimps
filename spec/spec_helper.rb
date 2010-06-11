CHIMPS_ROOT_DIR = File.join(File.expand_path(File.dirname(__FILE__)), '..') unless defined? CHIMPS_ROOT_DIR
CHIMPS_SPEC_DIR = File.join(CHIMPS_ROOT_DIR, 'spec')                        unless defined? CHIMPS_SPEC_DIR
CHIMPS_LIB_DIR  = File.join(CHIMPS_ROOT_DIR, 'lib')                         unless defined? CHIMPS_LIB_DIR
$: << CHIMPS_LIB_DIR

require 'rubygems'
require 'spec'
require 'chimps'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |path| require path }

module Chimps
  module Test
    TMP_DIR   = "/tmp/chimps_test" unless defined?(TMP_DIR)
  end
end

Spec::Runner.configure do |config|
  config.include Chimps::Test::CustomMatchers

  config.before do
    FileUtils.mkdir_p Chimps::Test::TMP_DIR
    FileUtils.cd Chimps::Test::TMP_DIR
  end
  
  config.after do
    FileUtils.rm_rf Chimps::Test::TMP_DIR
  end
  
end
