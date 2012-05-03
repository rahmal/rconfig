require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RConfig do
  before :each do
    RConfig.load_paths = ['spec/config']
  end

  context 'reading config' do
    it 'should read config for the specified file' do
      RConfig.spec.should == CONFIG
    end

    it 'should read xml files' do
      RConfig.xml_config.should == CONFIG2
    end

    it 'should read property files' do
      RConfig.props_config.should == CONFIG2
    end

    it 'accept string keys' do
      RConfig.spec['admin'].should == CONFIG['admin']
    end

    it 'should accept symbol keys' do
      RConfig.spec[:admin].should == CONFIG['admin']
    end

    it 'should accept keys by method invocation' do
      RConfig.spec.admin.should == CONFIG['admin']
    end

    it 'should return empty config for bad file names' do
      RConfig.bad.should be_blank
    end

    it 'should return nil for bad properties' do
      RConfig.spec.bad.should be_nil
    end

    it 'should parse erb contents' do
      RConfig.erb_contents.admin.name.should == ENV['USER']
      RConfig.erb_contents.admin.home.should == ENV['HOME']
    end
  end

  context 'parsing files' do
    it 'should raise error for bad file types' do
      contents = %Q{{"admin"=>{"name"=>"/Users/rahmal", "home"=>"rahmal"}}}
      lambda { RConfig.parse(contents, 'some_file', :bad) }.should raise_error(RConfig::ConfigError)
    end

    it 'should parse properties files with PropertiesFile parser' do
      contents = %Q{{"admin"=>{"name"=>"/Users/rahmal", "home"=>"rahmal"}}}
      RConfig::PropertiesFile.should_receive(:parse).with(contents)
      RConfig.parse(contents, 'props_file', :conf)
    end

    it 'should parse xml files with activesupport hash' do
      contents = "<admin><name>/Users/rahmal</name><home>rahmal</home></admin>"
      Hash.should_receive(:from_xml).with(contents)
      RConfig.parse(contents, 'xml_file', :xml)
    end
  end
end
