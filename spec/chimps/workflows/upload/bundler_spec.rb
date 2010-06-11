require File.join(File.dirname(__FILE__), '../../../spec_helper')

describe Chimps::Workflows::Upload::Bundler do

  before do
    @dataset             = 'foobar'
    @extant_path         = File.expand_path("extant_file.txt")
    @non_extant_path     = File.expand_path("non_extant_file.txt")
    @archive_path        = File.expand_path("archive.tar.bz2")
    @extant_archive_path = File.expand_path("extant_archive.tar.bz2")

    
    File.open(@extant_path, 'w') { |f| f.write("some content") }
    File.open(@extant_archive_path, 'w') { |f| f.write("some, admittedly not very tar.bz2'ish, content") }
  end

  describe "setting the format of a bundle of input paths" do
    it "should accept a format when given" do
      bundler = Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_path], :fmt => 'foobar')
      bundler.fmt.should == 'foobar'
    end

    it "should guess a format when one isn't given" do
      bundler = Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_path])
      bundler.fmt.should == 'txt'
    end
  end

  describe "setting the archive from a bundle of input paths" do

    it "should automatically set the archive path when given no other information" do
      bundler = Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_path])
      File.basename(bundler.archive.path).should =~ /^chimps_/
    end

    it "should use a valid archive path when given one" do
      bundler = Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_path], :archive => 'foo.tar.bz2')
      File.basename(bundler.archive.path).should == 'foo.tar.bz2'
    end

    it "should raise an error when given a non-package or compressed-file archive path" do
      lambda { Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_path], :archive => 'foo.txt') }.should raise_error(Chimps::PackagingError)
    end

    it "should raise an error when given a compressed-file archive path with multiple input paths" do
      lambda { Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_path, @extant_archive_path], :archive => 'foo.bz2') }.should raise_error(Chimps::PackagingError)
    end
    
  end

  describe "processing input paths" do

    it "should raise an error when no paths are given" do
      lambda { Chimps::Workflows::Upload::Bundler.new(@dataset, []) }.should raise_error(Chimps::PackagingError)
    end

    it "should raise an error when given a local path which doesn't exist" do
      lambda { Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_path, @non_extant_path]) }.should raise_error(IMW::PathError)
    end

    it "should set its archive path and skip packaging when passed a single, extant archive path" do
      bundler = Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_archive_path])
      bundler.skip_packaging?.should be_true      
      bundler.archive.path.should == @extant_archive_path
    end

    it "should prefer the explicitly passed in archive path to the implicitly seleced archive path when passed a 1-path input array consisting of an archive as well as the :archive option" do
      bundler = Chimps::Workflows::Upload::Bundler.new(@dataset, [@extant_archive_path], :archive => "foo.tar.bz2")
      File.basename(bundler.archive.path).should == 'foo.tar.bz2'
    end
    
  end
  
end

