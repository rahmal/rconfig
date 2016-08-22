require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RConfig do
  before :each do
    RConfig.load_paths = ['spec/config']
  end

  context 'reload' do
    it 'should reload when path is added' do
      RConfig.should_receive(:reload).with(true).and_return(true)
      RConfig.add_load_path('spec')
    end

    it 'should reload if reload enabled' do
      RConfig.enable_reload = true
      RConfig.reload.should be_truthy
    end

    it 'should not reload if reload disabled' do
      RConfig.enable_reload = false
      RConfig.reload.should be_falsey
    end

    it 'should reload if forced' do
      RConfig.enable_reload = false
      RConfig.reload(true).should be_truthy
    end

    it 'should flush cache on reload' do
      RConfig.should_receive(:flush_cache)
      RConfig.reload(true)
      RConfig.cache.should == {}
    end

  end

end
