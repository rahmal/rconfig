ROOT_DIR = File.expand_path(File.dirname(__FILE__))
CONF_DIR = File.join(ROOT_DIR, 'config')

# Set the environment to test
ENV['CONFIG_ENV'] = 'test'

# Host-specific config to test cascade logic
cascade_host_file = File.join(File.dirname(__FILE__),'config',"cascade2_#{Socket.gethostname}.yml")
unless File.exist?(cascade_host_file)
   cascade_original_file = File.join(File.dirname(__FILE__),'config','cascade2_host.yml')
   FileUtils.copy(cascade_original_file, cascade_host_file)
end

# Loads the rconfig library
$LOAD_PATH << File.join(ROOT_DIR, '..', 'lib')

require 'yaml'
require 'active_support'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash/conversions'
require 'rconfig'

RConfig.setup do |config|
  config.load_paths = ['spec/config']
  config.file_types = [:yml, :xml, :conf]
  config.logger = RConfig::DisabledLogger.new
end

CONFIG  = YAML.load_file(CONF_DIR + '/spec.yml')
CONFIG2 = Hash.from_xml(File.read(CONF_DIR + '/xml_config.xml'))['xml_config']
