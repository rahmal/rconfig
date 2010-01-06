ROOT_DIR = File.expand_path(File.dirname(__FILE__))
CONF_DIR = File.join(ROOT_DIR, '..', 'test', 'config_files')

STDOUT.puts "ROOT_DIR: #{ROOT_DIR}"
STDOUT.puts "CONF_DIR: #{CONF_DIR}"

# Loads the rconfig library
$LOAD_PATH << File.join(ROOT_DIR, '..', 'lib')

require 'rconfig'

RConfig.initialize CONF_DIR, nil, true, true

# Requires supporting files in ./support/ and its subdirectories.
#Dir["#{ROOT_DIR}/support/**/*.rb"].each {|f| require f}

