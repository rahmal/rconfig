
ROOT_DIR = File.expand_path(File.dirname(__FILE__))
CONF_DIR = File.join(ROOT_DIR, 'test', 'config_files')

# Set test config environment
ENV['TIER'] = 'development'
ENV['CONFIG_PATH'] = CONF_DIR
ENV['LOG_LEVEL'] = 'verbose'

# Loads the rconfig library
$LOAD_PATH << File.join(ROOT_DIR,'..','lib')

# Requires supporting files in ./support/ and its subdirectories.
#Dir["#{ROOT_DIR}/support/**/*.rb"].each {|f| require f}

