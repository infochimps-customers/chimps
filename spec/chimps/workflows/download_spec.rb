require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Chimps::Download do
  before do
    @download = Chimps::Download.new('foobar')
  end
  
  describe "downloading" do
    before do
      @basename   = "data.tar.gz"
      @signed_url = "http://bucket.aws.amazon.com/path/to/#{@basename}?this=is&aFake=SignedURL"
      @download.stub!(:signed_url).and_return(@signed_url)
    end
    
    it "should write to a sensibly named file when given a directory" do
      @download.should_receive(:curl).with(@signed_url, { :output => File.join('/tmp', @basename) })
      @download.download('/tmp')
    end

    it "should write to a path when given a path" do
      @download.should_receive(:curl).with(@signed_url, { :output => '/wukka/wukka.tar.gz' })
      @download.download('/wukka/wukka.tar.gz')
    end
  end

  describe "extracting a signed URL from a download token" do
    before do
      @token = {}
      @token.stub!(:parse)
      @download.stub!(:token).and_return(@token)
    end

    it "should raise an Error if the token doesn't have a signed URL " do
      lambda { @download.signed_url }.should raise_error(Chimps::Error)
      @token['download_token'] = {'foo' => 'bar'}
      lambda { @download.signed_url }.should raise_error(Chimps::Error)
    end

    it "should return the signed URL from the token when present" do
      @token['download_token'] = {'signed_url' => 'foobar'}
      @download.signed_url.should == 'foobar'
    end
  end
  
end



