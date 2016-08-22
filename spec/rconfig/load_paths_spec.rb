require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RConfig do
  before :each do
    RConfig.load_paths = ['spec/config']
  end

  context 'load paths' do
    it 'should have a valid load path' do
      RConfig.load_paths.should_not be_blank
      RConfig.load_paths.all?{|path| File.exists?(path) }.should be_truthy
    end

    it 'should allow multiple load paths' do
      lambda { RConfig.add_load_path('spec/config2') }.should_not raise_error
      RConfig.load_paths.size.should == 2
    end

    it 'should not allow duplicate load paths' do
      RConfig.add_load_path('spec/config')
      RConfig.load_paths.size.should == 1
    end

    it 'should not allow nil paths' do
      lambda { RConfig.add_load_path(nil) }.should raise_error(ArgumentError)
    end

    it 'should not allow blank paths' do
      lambda { RConfig.add_load_path('') }.should raise_error(ArgumentError)
    end

    it 'shoud not allow paths that do not exist' do
      lambda { RConfig.add_load_path('/bad/path') }.should raise_error(RConfig::InvalidLoadPathError)
    end
  end

end
