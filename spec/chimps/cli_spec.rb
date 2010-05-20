require File.join(File.dirname(__FILE__), '../spec_helper')

describe Chimps::CLI do
end

describe Chimps::CLI::Runner do

  it "should raise a CLIError when no command is given" do
    lambda { Chimps::CLI::Runner.new([]).execute! }.should raise_error(Chimps::CLIError)
  end

  it "should raise a CLIError when an unrecognized command is given" do
    lambda { Chimps::CLI::Runner.new(['foobar', 'arg1', 'arg2']).execute! }.should raise_error(Chimps::CLIError)
  end

  it "should recognize a command when given" do
    Chimps::Commands.should_receive(:construct).with('list', ['arg1', 'arg2'])
    Chimps::CLI::Runner.new(['list', 'arg1', 'arg2']).command # execute requires the command to be initialized and returned...
  end
  
end

