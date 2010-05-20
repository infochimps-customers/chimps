require File.join(File.dirname(__FILE__), '../../spec_helper')

describe Chimps::Command do

  it "should return its full name" do
    Chimps::Command.name.should == "chimps::command"
  end

  it "should return just its command name" do
    Chimps::Command.new([]).name.should == "command"
  end

  it "should run any methods beginning with `define' and ending with `options?'" do
    klass = Class.new(Chimps::Command)
    klass.class_eval <<RUBY
      attr_accessor :test_property
      def define_test_options
        self.test_property=true
      end
RUBY
    klass.new([]).test_property.should == true
  end
  
  
end
