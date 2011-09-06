require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Chimps::QueryRequest do

  before do
    Chimps.config[:query][:host]  = 'http://qubar.com'
    Chimps.config[:apikey]   = 'spec_key'
  end

  describe "generating the base URL with query string" do
    it "should join the path to the Infochimps query host" do
      Chimps::QueryRequest.new('/path/to/something').base_url.should == 'http://qubar.com/path/to/something'
    end
    it "should generate the same base URL regardless of whether the path has a leading '/' or not" do
      Chimps::QueryRequest.new('/path/to/something').base_url.should == Chimps::QueryRequest.new('path/to/something').base_url
    end
  end

  describe "generating the query string" do
    it "should add apikey and requested_at params by default" do
      qs = Chimps::QueryRequest.new('/path/to/something').query_string
      qs.should     include('apikey')
      qs.should     include('requested_at')
      qs.should_not include('signature')
    end

    it "should properly URL encode the query string it generates" do
      Chimps::QueryRequest.new('/path/to/something', :query_params => {:foo => 'bar baz'}).query_string.should include('foo=bar%20baz')
    end

    it "should raise an error if no credentials are available" do
      Chimps.config[:apikey] = nil
      lambda { Chimps::QueryRequest.new('/path/to/something').query_string }.should raise_error(Chimps::AuthenticationError)
    end

    it "should allow setting a raw query string" do
      Chimps::QueryRequest.new('/path/to/something', :query => 'foo=bar', :raw => true).query_string.should == 'foo=bar'
    end
  end
  
end



