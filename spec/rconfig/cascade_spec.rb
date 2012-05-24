require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RConfig do
  before :each do
    RConfig.load_paths = ['spec/config']
  end

  context 'cascading configs' do
    it 'should set ENV_TIER from CONFIG_ENV' do
      RConfig::Constants::ENV_TIER.should == ENV['CONFIG_ENV']
    end

    it 'should set hostname from the host machine' do
      RConfig::Constants::HOSTNAME.should == Socket.gethostname
    end

    it 'should use values from env-specific config when present' do
      RConfig.cascade.server.ip.should == '222.222.222.222'
      RConfig.cascade.server.port.should == 8080
    end

    it 'should use value from base config when property does not exist in env-specific config' do
      RConfig.cascade.server.hostname.should == 'test_host'
    end

    it 'should give host-based configs precedence over env-based configs' do
      RConfig.cascade2.server.ip.should == '333.333.333.333'
      RConfig.cascade2.server.port.should == 9090
    end

  end
end
