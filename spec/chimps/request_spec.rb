require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Chimps::Request do

  before do
    Chimps.config[:catalog][:host]   = 'http://foobar.com'
    Chimps.config[:catalog][:key]    = 'spec_key'
    Chimps.config[:catalog][:secret] = 'secret'
  end

  describe "generating the base URL with query string" do
    it "should join the path to the Infochimps site host" do
      Chimps::Request.new('/path/to/something').base_url.should == 'http://foobar.com/path/to/something'
    end
    it "should generate the same base URL regardless of whether the path has a leading '/' or not" do
      Chimps::Request.new('/path/to/something').base_url.should == Chimps::Request.new('path/to/something').base_url
    end
  end

  describe "generating the query string" do
    it "should generate no query string by default" do
      Chimps::Request.new('/path/to/something').query_string.should_not include('?')
    end

    it "should encode a Hash of query string parameters when given" do
      Chimps::Request.new('/path/to/something', :query_params => {:foo => 'bar', :fuzz => 'booz'}).query_string.should include('foo=bar', 'fuzz=booz')
    end

    it "should properly URL encode the query string it generates" do
      Chimps::Request.new('/path/to/something', :query_params => {:foo => 'bar baz'}).query_string.should == 'foo=bar%20baz'
    end

    it "should sign the URL it generates if asked to" do
      qs = Chimps::Request.new('/path/to/something', :sign => true).query_string
      qs.should include('apikey')
      qs.should include('requested_at')
      qs.should include('signature')
    end

    it "should raise an error if asked to sign and no credentials are available" do
      Chimps.config[:catalog][:key] = nil
      lambda { Chimps::Request.new('/path/to/something', :sign => true).query_string }.should raise_error(Chimps::AuthenticationError)
    end

    it "should not raise an error if asked to sign_if_possible and no credentials are avialable" do
      Chimps.config[:catalog][:key] = nil
      lambda { Chimps::Request.new('/path/to/something', :sign_if_possible => true).query_string }.should_not raise_error(Chimps::AuthenticationError)
    end

    it "should allow setting a raw query string" do
      Chimps::Request.new('/path/to/something', :query => 'foo=bar', :raw => true).query_string.should == 'foo=bar'
    end
  end

  describe "generating the request body" do
    it "should have no body by default" do
      Chimps::Request.new('/path/to/something').body.should be_empty
    end

    it "should encode a Hash of parameters when given" do
      Chimps::Request.new('/path/to/something', :body => { :foo => 'bar' }).encoded_body.should == '{"foo":"bar"}'
    end

    it "should sign the body when it exists" do
      request = Chimps::Request.new('/path/to/something', :body => { :foo => 'bar'}, :sign => true)
      request.should_receive(:sign).with('{"foo":"bar"}')
      request.query_string
    end

    it "should allow setting a raw body" do
      Chimps::Request.new('/path/to/something', :body => '{"foo": "bar"}', :raw => true).encoded_body.should == '{"foo": "bar"}'
    end
    
  end

  describe "making a request" do
    it "should swallow low-level networking errors" do
      Chimps::Request.new('/some/made/up/path').get.code.should == 404
    end

    it "should swallow application-level errors" do
      Chimps.config[:catalog][:host]   = 'http://www.infochimps.com'
      Chimps::Request.new('/some/made/up/path').get.code.should == 404
    end

  end
    
  
end



